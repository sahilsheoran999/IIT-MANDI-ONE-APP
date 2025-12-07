import 'package:flutter/material.dart';
import 'package:project/styles/fontstyle.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  List<String> events = ['Exodia', 'Xpecto', 'Miraz'];
  List<String> images= ['assets/exodia.png','assets/xpecto.png','assets/miraz.png'];
  List<String> url=['https://www.instagram.com/exodia.iitmandi/?hl=en','https://www.xpecto.org/','https://www.instagram.com/miraz.iitmandi/'];
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    void _showWebViewBottomSheet(BuildContext context, String url, String title) {
    // Create the controller outside the builder
    final controller = WebViewController()
      ..loadRequest(Uri.parse(url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: subheadingStyle(context)),
                    
                  ],
                ),
              ),
              // WebView content
              Expanded(
                child: WebViewWidget(
                  controller: controller,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: events.length,
      padding: EdgeInsets.symmetric(vertical: 8), // Add padding to prevent clipping
      itemBuilder: (context, index) {
        return Container(
          height: h/5, // Make sure this height is appropriate
          width: w/1.5,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Add vertical margin
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Top colored container
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {_showWebViewBottomSheet(context, url[index], events[index]);},
                    child: Container(
                      height: h*(2/9.5),
                      decoration: BoxDecoration(image: DecorationImage(image: AssetImage(images[index]), fit: BoxFit.fill)),
                    ),
                  ),
                ),
                // Text at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      events[index],
                      style: subheadingStyle(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}