import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project/styles/fontstyle.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  
  User? _currentUser;
  String? _userEmail;
  List<String> _joinedCommunities = [];
  List<Map<String, dynamic>> _availableCommunities = [];
  List<Map<String, dynamic>> _communityPosts = [];
  bool _isLoading = true;
  String? _selectedCommunityId;
  String? _errorMessage;
  String? _selectedCommunityName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isModerator = false;
  List<String> _moderatedCommunities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _currentUser = _auth.currentUser;
      _userEmail = _currentUser?.email;
      
      if (_userEmail == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated. Please log in.';
        });
        return;
      }

      // Check if user is a moderator and get moderated communities
      DocumentSnapshot moderatorDoc = await _firestore.collection('moderators').doc(_userEmail).get();
      if (moderatorDoc.exists) {
        setState(() {
          _isModerator = true;
          _moderatedCommunities = List<String>.from(moderatorDoc['moderatedCommunities'] ?? []);
        });
      }

      // Load user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userEmail).get();
      if (userDoc.exists) {
        setState(() {
          _joinedCommunities = List<String>.from(userDoc['joinedCommunities'] ?? []);
        });
      }

      // Load communities
      QuerySnapshot communitiesSnapshot = await _firestore.collection('communities').get();
      
      List<Map<String, dynamic>> communities = [];
      for (var doc in communitiesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        communities.add({
          'id': doc.id,
          'name': data['name']?.toString() ?? 'Unnamed Community',
          'description': data['description']?.toString() ?? 'No description available',
          'isJoined': _joinedCommunities.contains(doc.id),
        });
      }

      setState(() {
        _availableCommunities = communities;
        _isLoading = false;
      });

      if (_joinedCommunities.isNotEmpty) {
        _selectCommunity(_joinedCommunities.first);
      } else {
        setState(() {
          _selectedCommunityId = null;
          _selectedCommunityName = null;
          _communityPosts = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
      debugPrint('Error initializing data: $e');
    }
  }

  Future<void> _selectCommunity(String communityId) async {
    if (communityId.isEmpty) return;
    
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    setState(() {
      _selectedCommunityId = communityId;
      _isLoading = true;
      _errorMessage = null;
      
      final selectedCommunity = _availableCommunities.firstWhere(
        (c) => c['id'] == communityId,
        orElse: () => {'name': 'Community'},
      );
      _selectedCommunityName = selectedCommunity['name'];
    });
    
    try {
      DataSnapshot postsSnapshot = await _rtdb.child('posts/$communityId').get();
      
      List<Map<String, dynamic>> posts = [];
      if (postsSnapshot.value != null) {
        Map<dynamic, dynamic> postsData = postsSnapshot.value as Map<dynamic, dynamic>;
        posts = postsData.entries.map((entry) {
          return {
            'id': entry.key,
            'title': entry.value['title'] ?? '',
            'content': entry.value['content'] ?? '',
            'timestamp': DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(entry.value['timestamp'].toString()) ?? DateTime.now().millisecondsSinceEpoch),
            'sender': entry.value['sender'] ?? 'Unknown',
            'isModeratorPost': entry.value['isModeratorPost'] ?? false,
          };
        }).toList();
        
        posts.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      }
      
      setState(() {
        _communityPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load posts: ${e.toString()}';
      });
      debugPrint('Error loading posts: $e');
    }
  }

  Future<void> _joinCommunity(String communityId) async {
    if (_userEmail == null) return;
    
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayUnion([_userEmail]),
      });
      
      await _firestore.collection('users').doc(_userEmail).update({
        'joinedCommunities': FieldValue.arrayUnion([communityId]),
      });
      
      setState(() {
        _joinedCommunities.add(communityId);
        _availableCommunities = _availableCommunities.map((community) {
          if (community['id'] == communityId) {
            return {...community, 'isJoined': true};
          }
          return community;
        }).toList();
      });
      
      _selectCommunity(communityId);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to join community: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Failed to join community: ${e.toString()}', style: normalsize(context))),
      );
      debugPrint('Error joining community: $e');
    }
  }

  Future<void> _leaveCommunity(String communityId) async {
    if (_userEmail == null) return;
    
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayRemove([_userEmail]),
      });
      
      await _firestore.collection('users').doc(_userEmail).update({
        'joinedCommunities': FieldValue.arrayRemove([communityId]),
      });
      
      setState(() {
        _joinedCommunities.remove(communityId);
        _availableCommunities = _availableCommunities.map((community) {
          if (community['id'] == communityId) {
            return {...community, 'isJoined': false};
          }
          return community;
        }).toList();
      });
      
      if (_selectedCommunityId == communityId) {
        if (_joinedCommunities.isNotEmpty) {
          _selectCommunity(_joinedCommunities.first);
        } else {
          setState(() {
            _selectedCommunityId = null;
            _selectedCommunityName = null;
            _communityPosts = [];
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to leave community: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Failed to leave community: ${e.toString()}', style: normalsize(context))),
      );
      debugPrint('Error leaving community: $e');
    }
  }

  Future<void> _createPost(String title, String content) async {
    if (_userEmail == null || _selectedCommunityId == null) return;
    
    // Check if user is moderator for this specific community
    if (!_isModerator || !_moderatedCommunities.contains(_selectedCommunityId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF1E1E1F),
          content: Text('Only moderators of this community can create posts', style: normalsize(context)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      DatabaseReference newPostRef = _rtdb.child('posts/$_selectedCommunityId').push();
      await newPostRef.set({
        'title': title,
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sender': _userEmail,
        'isModeratorPost': true,
      });
      
      await _selectCommunity(_selectedCommunityId!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF1E1E1F),
          content: Text('Post created successfully', style: normalsize(context)),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF1E1E1F),
          content: Text('Failed to create post: ${e.toString()}', style: normalsize(context)),
          duration: Duration(seconds: 2),
        ),
      );
      debugPrint('Error creating post: $e');
    }
  }

  void _showCreatePostBottomSheet() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF283021),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xFFB8C4AB),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Create New Post',
                style: subheadingStyle(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title (optional)',
                  labelStyle: normalsize(context).copyWith(color: Color(0xFFB8C4AB)),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB8C4AB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB8C4AB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
                style: normalsize(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: normalsize(context).copyWith(color: Color(0xFFB8C4AB)),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB8C4AB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB8C4AB), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
                style: normalsize(context).copyWith(color: Colors.white),
                maxLines: 5,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: normalsize(context).copyWith(color: Color(0xFFB8C4AB)),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (contentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Color(0xFF1E1E1F),content: Text('Content cannot be empty', style: normalsize(context))),
                        );
                        return;
                      }
                      _createPost(
                        titleController.text.trim(),
                        contentController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Post',
                      style: normalsize(context).copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7A9064),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityIcon(String communityId) {
    switch(communityId.toLowerCase()) {
      case 'announcements':
        return Icon(Icons.announcement, size: 30, color: Color(0xFFb8c4ab));
      case 'events':
        return Icon(Icons.event, size: 30, color: Color(0xFFb8c4ab));
      case 'study_group':
        return Icon(Icons.school, size: 30, color: Color(0xFFb8c4ab));
      default:
        return Icon(Icons.group, size: 30, color: Color(0xFFb8c4ab));
    }
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Communities',
            style: mainHeadingStyle(context),
          ),
          SizedBox(height: 8),
          Text(
            'Select a community to view posts',
            style: normalsize(context),
          ),
          Spacer(),
          Text(
            'Logged in as:',
            style: normalsize(context),
          ),
          Text(
            _userEmail ?? 'Not logged in',
            style: subheadingStyle(context),
            overflow: TextOverflow.ellipsis,
          ),
          
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Available Communities',
                    style: subheadingStyle(context),
                  ),
                ),
                if (_availableCommunities.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No communities available',
                      style: normalsize(context),
                    ),
                  ),
                ..._availableCommunities.map((community) {
                  return ListTile(
                    leading: _buildCommunityIcon(community['id']),
                    title: Text(community['name'], style: normalsize(context)),
                    subtitle: Text(
                      community['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalsize(context),
                    ),
                    selected: _selectedCommunityId == community['id'],
                    onTap: () => _selectCommunity(community['id']),
                    trailing: community['isJoined']
                        ? IconButton(
                            icon: Icon(Icons.exit_to_app, size: 20, color: Color(0xFFb8c4ab)),
                            onPressed: () => _leaveCommunity(community['id']),
                            tooltip: 'Leave community',
                          )
                        : ElevatedButton(
                            child: Text('Join', style: normalsize(context)),
                            onPressed: () => _joinCommunity(community['id']),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size(60, 30),
                              iconColor: Color(0xFFb8c4ab),
                            ),
                          ),
                  );
                }).toList(),
              ],
            ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Color(0xFF7a9064),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post['title']?.isNotEmpty ?? false)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (post['isModeratorPost'] ?? false)
                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.verified, size: 16, color: Color(0xFFb8c4ab)),
                      ),
                    Expanded(
                      child: Text(
                        post['title'],
                        style: subheadingStyle(context),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              post['content'],
              style: normalsize(context),
            ),
            SizedBox(height: 12),
            Text(
              'Posted by ${post['sender']}',
              style: normalsize(context),
            ),
            Text(
              '${post['timestamp'].toString()}',
              style: normalsize(context),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowCreateButton() {
    return _selectedCommunityId != null && 
        _availableCommunities.any((c) => c['id'] == _selectedCommunityId && c['isJoined']) &&
        _isModerator && 
        _moderatedCommunities.contains(_selectedCommunityId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _selectedCommunityName ?? 'Communities',
          style: mainHeadingStyle(context),
        ),
        backgroundColor: Color(0x20221B),
        iconTheme: IconThemeData(color: Color(0xFFb8c4ab)),
      ),
      floatingActionButton: _shouldShowCreateButton()
          ? FloatingActionButton(
              onPressed: _showCreatePostBottomSheet, // Changed to use the bottom sheet
              child: Icon(Icons.add, color: Colors.white),
              tooltip: 'Create new post',
              backgroundColor: Color(0xFF283021),
            )
          : null,
      endDrawer: _buildDrawer(),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFb8c4ab), size: 48),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: subheadingStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _initializeData,
                      child: Text('Retry', style: normalsize(context)),
                      style: ElevatedButton.styleFrom(
                        iconColor: Color(0xFFb8c4ab),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _isLoading
              ? Center(child: CircularProgressIndicator(color: Color(0xFFb8c4ab)))
              : _selectedCommunityId == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_outlined, size: 64, color: Color(0xFFb8c4ab)),
                          SizedBox(height: 16),
                          Text(
                            'No community selected',
                            style: subheadingStyle(context),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Open the drawer to join or select a community',
                            style: normalsize(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.menu, color: Colors.white),
                            label: Text('Open Communities', style: normalsize(context).copyWith(color: Colors.white)),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            style: ElevatedButton.styleFrom(
                              iconColor: Color(0xFFb8c4ab),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _communityPosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              SizedBox(height: 16),
                              Text(
                                'No posts yet in this community',
                                style: subheadingStyle(context),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _isModerator && _moderatedCommunities.contains(_selectedCommunityId)
                                    ? 'You can create posts as a moderator'
                                    : 'Only moderators can create posts',
                                style: normalsize(context),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                           
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => _selectCommunity(_selectedCommunityId!),
                                color: Color(0xFFb8c4ab),
                                child: ListView.builder(
                                  padding: EdgeInsets.only(bottom: 16),
                                  itemCount: _communityPosts.length,
                                  itemBuilder: (context, index) {
                                    return _buildPostItem(_communityPosts[index]);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }
}