import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(StudentDataUploaderApp());
}

class StudentDataUploaderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Data Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentDataUploaderScreen(),
    );
  }
}

class StudentDataUploaderScreen extends StatefulWidget {
  @override
  _StudentDataUploaderScreenState createState() => _StudentDataUploaderScreenState();
}

class _StudentDataUploaderScreenState extends State<StudentDataUploaderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;
  int _successCount = 0;
  int _failureCount = 0;
  List<String> _failedUploads = [];

  final List<Map<String, String>> students = [
   {"rollNumber": "B23297", "name": "SOHAN HALDER"},
    {"rollNumber": "B23298", "name": "SONALI BARA"},
    {"rollNumber": "B23299", "name": "SUMIT TIWARI"},
    {"rollNumber": "B23300", "name": "TANISHA SINGH"},
    {"rollNumber": "B23301", "name": "THAMANNA A MAJEED"},
    {"rollNumber": "B23302", "name": "VINAMRA GARG"},
    {"rollNumber": "B23303", "name": "VISHWAS JASUJA"},
    {"rollNumber": "B23304", "name": "YASH"},
    {"rollNumber": "B23305", "name": "YASH GAUTAM"},
    {"rollNumber": "B23306", "name": "ADARSH TRIPATHI"},
    {"rollNumber": "B23307", "name": "ADITI GUPTA"},
    {"rollNumber": "B23308", "name": "ADITYA KUMAR GUPTA"},
    {"rollNumber": "B23309", "name": "ANANYA NITIN GAWADE"},
    {"rollNumber": "B23310", "name": "ANUSHKA CHAUHAN"},
    {"rollNumber": "B23312", "name": "DEEPAK K SHEGAVI"},
    {"rollNumber": "B23313", "name": "GADDE AMAR SAI"},
    {"rollNumber": "B23314", "name": "HARGYAN MEENA"},
    {"rollNumber": "B23316", "name": "K V DHEERAJ REDDY"},
    {"rollNumber": "B23317", "name": "KAMESH SINGH"},
    {"rollNumber": "B23318", "name": "KAMUGARU AJAY GOUD"},
    {"rollNumber": "B23319", "name": "KARAN GERA"},
    {"rollNumber": "B23320", "name": "KRATIKA SINGH"},
    {"rollNumber": "B23322", "name": "MAHENDERKAR THANOOJU"},
    {"rollNumber": "B23323", "name": "MARTHA THRIGHUN"},
    {"rollNumber": "B23325", "name": "MOHIT KUMAR"},
    {"rollNumber": "B23326", "name": "NEELESH CHOUDHARY"},
    {"rollNumber": "B23327", "name": "PIYUSH THAKUR"},
    {"rollNumber": "B23328", "name": "PRAGYANSH SAXENA"},
    {"rollNumber": "B23329", "name": "PRIYANKA"},
    {"rollNumber": "B23333", "name": "SHRISH MOHAN UIKEY"},
    {"rollNumber": "B23334", "name": "SIDDHANT PREMAL SHAH"},
    {"rollNumber": "B23335", "name": "ABHINAV CHOUDHARY"},
    {"rollNumber": "B23336", "name": "AKSHAT JHA"},
    {"rollNumber": "B23337", "name": "AKSHAY MUKKERA"},
    {"rollNumber": "B23338", "name": "AMOOLYA PANDEY"},
    {"rollNumber": "B23339", "name": "ANUJ PAL"},
    {"rollNumber": "B23340", "name": "ARNAV CHANCHAL"},
    {"rollNumber": "B23341", "name": "BHARAT AGRAWAL"},
    {"rollNumber": "B23342", "name": "CHAWAN SAIRAM"},
    {"rollNumber": "B23343", "name": "DIKSHANT CHAUHAN"},
    {"rollNumber": "B23345", "name": "HARSH SANDEEP PATIL"},
    {"rollNumber": "B23346", "name": "HIMADRI SINGH"},
    {"rollNumber": "B23347", "name": "KARTIK VINOD REWATKAR"},
    {"rollNumber": "B23348", "name": "KHUSHAL"},
    {"rollNumber": "B23349", "name": "KORLAPATI JNANA SATYA KESAVA"},
    {"rollNumber": "B23351", "name": "KUSUM AGRAWAL"},
    {"rollNumber": "B23352", "name": "LALIT KISHOR"},
    {"rollNumber": "B23353", "name": "MOHD BASIL KHAN"},
    {"rollNumber": "B23354", "name": "PIYUSH DWIVEDI"},
    {"rollNumber": "B23355", "name": "PIYUSH ROY"},
    {"rollNumber": "B23356", "name": "PRANAV PATIDAR"},
    {"rollNumber": "B23357", "name": "RISHABH DEV SINGH"},
    {"rollNumber": "B23358", "name": "SHUBH SAHU"},
    {"rollNumber": "B23359", "name": "SOURAV MAHIL"},
    {"rollNumber": "B23360", "name": "VASANI DARSHIL PRAKASHBHAI"},
    {"rollNumber": "B23361", "name": "VULLI NAVADHEER KUMAR"},
    {"rollNumber": "B23362", "name": "ABHINAV AGARWAL"},
    {"rollNumber": "B23363", "name": "ABHIRAJ KUNTAL"},
    {"rollNumber": "B23364", "name": "ANSHUMAN SARKAR"},
    {"rollNumber": "B23365", "name": "ATHARVA THOMBARE"},
    {"rollNumber": "B23366", "name": "AYUSH SAWARN"},
    {"rollNumber": "B23367", "name": "BHAVYAKRITHIKA SUNKARI"},
    {"rollNumber": "B23368", "name": "DEVARASETTI HARIKA"},
    {"rollNumber": "B23369", "name": "DHEERAJ JHA"},
    {"rollNumber": "B23370", "name": "GOURAV CHAUDHARY"},
    {"rollNumber": "B23371", "name": "GUNJEET KUMAWAT"},
    {"rollNumber": "B23372", "name": "GURMUKH SINGH"},
    {"rollNumber": "B23373", "name": "HARSH VARDHAN SHARMA"},
    {"rollNumber": "B23374", "name": "HRISHIKESH KEDAR KULKARNI"},
    {"rollNumber": "B23376", "name": "KORRA PAVAN NAYAK"},
    {"rollNumber": "B23377", "name": "KRISHNA UPADHYAY"},
    {"rollNumber": "B23378", "name": "MOHAMMAD ZUHEER"},
    {"rollNumber": "B23379", "name": "NIMIT GARG"},
    {"rollNumber": "B23381", "name": "PRADEEP BISHNOI"},
    {"rollNumber": "B23382", "name": "PRAKHAR KANWARIA"},
    {"rollNumber": "B23384", "name": "SALAVADI RITHESH"},
    {"rollNumber": "B23385", "name": "SANIA GOYAL"},
    {"rollNumber": "B23386", "name": "SHEJUL NIKHIL RAVINDRA"},
    {"rollNumber": "B23387", "name": "SHUBHANKIT SINGH"},
    {"rollNumber": "B23388", "name": "UTTPAL ADHIRAJ"},
    {"rollNumber": "B23389", "name": "YOGESH KUMAR"},
    {"rollNumber": "B23390", "name": "AARYA AGARWAL"},
    {"rollNumber": "B23391", "name": "ABHEY KUMAR"},
    {"rollNumber": "B23392", "name": "ADE AKSHITH NAIK"},
    {"rollNumber": "B23393", "name": "ALOK KUMAR"},
    {"rollNumber": "B23394", "name": "ARENDRA KUMAR"},
    {"rollNumber": "B23395", "name": "BHAVIK OSTWAL"},
    {"rollNumber": "B23396", "name": "DHRUV"},
    {"rollNumber": "B23397", "name": "DIVYANSH JAIN"},
    {"rollNumber": "B23398", "name": "GAURAV YADAV"},
    {"rollNumber": "B23399", "name": "ISHIKA AGARWAL"},
    {"rollNumber": "B23400", "name": "LAVISH SINGAL"},
    {"rollNumber": "B23401", "name": "MEHAK"},
    {"rollNumber": "B23402", "name": "NARESH MEENA"},
    {"rollNumber": "B23403", "name": "NISHITA GUPTA"},
    {"rollNumber": "B23404", "name": "PERUKA ROHITH PRANAV"},
    {"rollNumber": "B23405", "name": "PIYUSH KUMAR"},
    {"rollNumber": "B23406", "name": "RAJ MAURYA"},
    {"rollNumber": "B23407", "name": "RAJVEER TOMAR"},
    {"rollNumber": "B23408", "name": "RAVI"},
    {"rollNumber": "B23409", "name": "RIDDHIMA GOYAL"},
    {"rollNumber": "B23410", "name": "RIJVANA BANO"},
    {"rollNumber": "B23411", "name": "SAATVIK GAJENDRA PAREEK"},
    {"rollNumber": "B23412", "name": "SAHIL"},
    {"rollNumber": "B23414", "name": "SAURABH SINGH"},
    {"rollNumber": "B23415", "name": "SIDDHI SANDIP POGAKWAR"},
    {"rollNumber": "B23416", "name": "SUNKU VENKATA PRUDHVI NARAYANA"},
    {"rollNumber": "B23417", "name": "THACKER VYOM AMITBHAI"},
    {"rollNumber": "B23418", "name": "VANSH KAPOOR"},
    {"rollNumber": "B23419", "name": "VANSHDEEP SINGH"},
    {"rollNumber": "B23420", "name": "AARYAN TYAGI"},
    {"rollNumber": "B23421", "name": "ABHAY PRATAP SINGH"},
    {"rollNumber": "B23422", "name": "ABHIJEET SINGH"},
    {"rollNumber": "B23423", "name": "ACHINTYA DIXIT"},
    {"rollNumber": "B23425", "name": "ALI ASGAR MAHESHWARWALA"},
    {"rollNumber": "B23426", "name": "ALOK KUMAR YADAV"},
    {"rollNumber": "B23427", "name": "ALOORI ADVAITHESHA"},
    {"rollNumber": "B23428", "name": "ANAMIKA"},
    {"rollNumber": "B23429", "name": "AYUSH KUMAR"},
    {"rollNumber": "B23430", "name": "BADAL GUPTA"},
    {"rollNumber": "B23431", "name": "BHUKYA PRAVEEN KUMAR"},
    {"rollNumber": "B23432", "name": "BHUMI MUNDHARA"},
    {"rollNumber": "B23433", "name": "CHIRAG"},
    {"rollNumber": "B23434", "name": "DEEPAK"},
    {"rollNumber": "B23435", "name": "DHRUV AGARWAL"},
    {"rollNumber": "B23436", "name": "DHRUV KANSAL"},
    {"rollNumber": "B23437", "name": "DHRUVA RATHORE"},
    {"rollNumber": "B23438", "name": "DIVYANSHU RAJ"},
    {"rollNumber": "B23439", "name": "ERIC"},
    {"rollNumber": "B23440", "name": "GADDI DEVI SREE VISHAL"},
    {"rollNumber": "B23441", "name": "HARSH PANDEY"},
    {"rollNumber": "B23442", "name": "JAHANVI SONI"},
    {"rollNumber": "B23443", "name": "JATOTH PURNACHANDAR"},
    {"rollNumber": "B23444", "name": "JAYA PANDEY"},
    {"rollNumber": "B23445", "name": "KARTAVYA"},
    {"rollNumber": "B23446", "name": "KETAN CHANDRA"},
    {"rollNumber": "B23447", "name": "KHUSHI VIJAY"},
    {"rollNumber": "B23448", "name": "KRIPAL DAHARIYA"},
    {"rollNumber": "B23449", "name": "M VISHAL SRINIVAS"},
    {"rollNumber": "B23450", "name": "MIHIR KUMAR SINHA"},
    {"rollNumber": "B23451", "name": "MUKUL"},
    {"rollNumber": "B23452", "name": "PINISETTY RAVI KIRAN"},
    {"rollNumber": "B23453", "name": "PRANEETH KUMAR LAVUDYA"},
    {"rollNumber": "B23454", "name": "PRAVEEN KUMAR JHA"},
    {"rollNumber": "B23455", "name": "PRIYANSHU PRAJAPATI"},
    {"rollNumber": "B23456", "name": "PRIYANSHU SINHA"},
    {"rollNumber": "B23457", "name": "PUJAN PRANAVKUMAR PUROHIT"},
    {"rollNumber": "B23458", "name": "RAGHAV"},
    {"rollNumber": "B23459", "name": "RAHUL KUMAR"},
    {"rollNumber": "B23460", "name": "RISHI KATIYAR"},
    {"rollNumber": "B23461", "name": "SAGAR"},
    {"rollNumber": "B23462", "name": "SAHIL"},
    {"rollNumber": "B23463", "name": "SAMDEEP CHHABRA"},
    {"rollNumber": "B23464", "name": "SAPAVAT KARTHIK"},
    {"rollNumber": "B23465", "name": "SHIVAM ANAND"},
    {"rollNumber": "B23466", "name": "SHREYA GUPTA"},
    {"rollNumber": "B23467", "name": "SHUBHAM MEENA"},
    {"rollNumber": "B23468", "name": "SNEHA DAS"},
    {"rollNumber": "B23469", "name": "SUDHANSHU GAUTAM"},
    {"rollNumber": "B23470", "name": "SUJAL VERMA"},
    {"rollNumber": "B23471", "name": "TALLA BHAVANA"},
    {"rollNumber": "B23472", "name": "TANISHI A GUPTA"},
    {"rollNumber": "B23473", "name": "TUSHAR"},
    {"rollNumber": "B23474", "name": "VASUDEV SHARMA"},
    {"rollNumber": "B23475", "name": "VEEDHEE CHANNEY"},
    {"rollNumber": "B23476", "name": "VENGALATHURI SHRENIK SRIKANTH"},
    {"rollNumber": "B23477", "name": "YADNYIT SUNIL PANCHBHAI"},
    {"rollNumber": "B23478", "name": "YUG GOYAL"},
    {"rollNumber": "B23479", "name": "AAYUSH PATIDAR"},
    {"rollNumber": "B23480", "name": "ADIT RAJ"},
    {"rollNumber": "B23481", "name": "AKASH KUMAR"},
    {"rollNumber": "B23483", "name": "ANKUR AMAN"},
    {"rollNumber": "B23484", "name": "AYAN GARG"},
    {"rollNumber": "B23485", "name": "BHUVANESH GANTA"},
    {"rollNumber": "B23486", "name": "BITLA SRIKAR"},
    {"rollNumber": "B23487", "name": "CHINMAY PATEL"},
    {"rollNumber": "B23488", "name": "GARVIT GARG"},
    {"rollNumber": "B23489", "name": "GAWAI PRASHIK GAJANAN"},
    {"rollNumber": "B23490", "name": "GODABA JASMINI"},
    {"rollNumber": "B23491", "name": "HIMANSHI NAMDEV"},
    {"rollNumber": "B23492", "name": "HIMESH CHANDRAKAR"},
    {"rollNumber": "B23495", "name": "LODHA RUSHABH RAJENDRA"},
    {"rollNumber": "B23496", "name": "MULKALA GNANESHWAR"},
    {"rollNumber": "B23497", "name": "NANDA KISHORE YADLA"},
    {"rollNumber": "B23498", "name": "PALAVALASA PUNEETH"},
    {"rollNumber": "B23499", "name": "PARTH M MODI"},
    {"rollNumber": "B23500", "name": "ROHAK GUPTA"},
    {"rollNumber": "B23501", "name": "SHERSINGH MEENA"},
    {"rollNumber": "B23502", "name": "SHIWANG KHERA"},
    {"rollNumber": "B23503", "name": "SRI SAHITHI SUNKARANAM"},
    {"rollNumber": "B23504", "name": "TARANPREET SINGH"},
    {"rollNumber": "B23505", "name": "VANI DHIMAN"},
    {"rollNumber": "B23506", "name": "VULLI SHARANYA"},
    {"rollNumber": "B23507", "name": "YASHOVARDHAN REDDY BOREDDY"},
  ];

  Future<void> _uploadStudentData() async {
    setState(() {
      _isUploading = true;
      _successCount = 0;
      _failureCount = 0;
      _failedUploads = [];
    });

    for (var student in students) {
      try {
        // Convert rollNumber to lowercase for email
        String email = "${student['rollNumber']?.toLowerCase()}@students.iitmandi.ac.in";
        
        await _firestore.collection('users').doc(email).set({
          'name': student['name'],
          'rollNumber': student['rollNumber'], // Keep original case for rollNumber
          'role': 'student',
          'joinedCommunities': [],
          'email': email,
        });

        setState(() {
          _successCount++;
        });
      } catch (e) {
        setState(() {
          _failureCount++;
          _failedUploads.add("${student['rollNumber']}: ${student['name']}");
        });
        debugPrint("Failed to upload ${student['rollNumber']}: $e");
      }
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Data Uploader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Data Upload',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Students: ${students.length}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadStudentData,
              child: _isUploading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Upload Student Data'),
            ),
            SizedBox(height: 20),
            if (_isUploading) LinearProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Upload Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Successful uploads: $_successCount'),
            Text('Failed uploads: $_failureCount'),
            if (_failedUploads.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Failed Uploads:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _failedUploads.length,
                  itemBuilder: (context, index) {
                    return Text(_failedUploads[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}