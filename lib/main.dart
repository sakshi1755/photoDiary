import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690), // Base design size
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Responsive text scaling
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 20.sp),
          bodyLarge: TextStyle(fontSize: 16.sp),
        ),
      ),
      home: const PhotoListScreen(),
    );
  }
}

class PhotoEntry {
  String image;
  String caption;
  String entry;
  DateTime date;
  bool isexpanded;

  PhotoEntry({
    required this.image, 
    required this.caption, 
    required this.entry,
    DateTime? date,
    this.isexpanded = false
  }) : date = date ?? DateTime.now();
}

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  List<PhotoEntry> photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = photos.map((photo) => {
      'image': photo.image,
      'caption': photo.caption,
      'entry': photo.entry,
      'date': photo.date.toIso8601String(),
      'isexpanded': photo.isexpanded
    }).toList();
    await prefs.setString('photoEntries', json.encode(photosJson));
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getString('photoEntries');
    
    if (photosJson != null) {
      final List<dynamic> decodedPhotos = json.decode(photosJson);
      setState(() {
        photos = decodedPhotos.map((photoJson) => PhotoEntry(
          image: photoJson['image'] ?? 'assets/photo1.png',
          caption: photoJson['caption'] ?? 'A Beautiful Sunset',
          entry: photoJson['entry'] ?? '',
          date: DateTime.parse(photoJson['date'] ?? DateTime.now().toIso8601String()),
          isexpanded: photoJson['isexpanded'] ?? false
        )).toList();
      });
    }
  }

  void _editEntry(int index) {
    final TextEditingController entryController = TextEditingController(text: photos[index].entry);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Entry", style: TextStyle(fontSize: 18.sp)),
          content: TextField(
            controller: entryController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Update your entry",
              labelStyle: TextStyle(fontSize: 14.sp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos[index].entry = entryController.text;
                });
                _savePhotos();
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _editCaption(int index) {
    final TextEditingController captionController = TextEditingController(text: photos[index].caption);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Caption", style: TextStyle(fontSize: 18.sp)),
          content: TextField(
            controller: captionController,
            decoration: InputDecoration(
              labelText: "Update your caption",
              labelStyle: TextStyle(fontSize: 14.sp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos[index].caption = captionController.text;
                });
                _savePhotos();
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Entry", style: TextStyle(fontSize: 18.sp)),
          content: Text(
            "Are you sure you want to delete this photo entry?", 
            style: TextStyle(fontSize: 14.sp)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos.removeAt(index);
                });
                _savePhotos();
                Navigator.pop(context);
              },
              child: Text(
                "Delete", 
                style: TextStyle(fontSize: 14.sp, color: Colors.red)
              ),
            ),
          ],
        );
      },
    );
  }

  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();
  final TextEditingController entryController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _showAddEntryDialog(pickedFile.path);
    }
  }

  void _showAddEntryDialog(String image) {
    captionController.clear();
    entryController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Photo Entry", style: TextStyle(fontSize: 18.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(image), height: 150.h, width: 150.w, fit: BoxFit.cover),
              SizedBox(height: 10.h),
              TextField(
                controller: captionController,
                decoration: InputDecoration(
                  labelText: "Caption",
                  labelStyle: TextStyle(fontSize: 14.sp),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: entryController,
                decoration: InputDecoration(
                  labelText: "Entry",
                  labelStyle: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  photos.add(PhotoEntry(
                    image: image, 
                    caption: captionController.text, 
                    entry: entryController.text,
                    date: DateTime.now(),
                    isexpanded: false
                  ));
                });
                _savePhotos();
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    photos.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🌸 Photo Diary 🌸',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 26.sp,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 10,
        shadowColor: const Color.fromARGB(255, 193, 3, 66),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
          side: BorderSide(
            color: Colors.black,
            width: 3,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 227, 17, 87),
                const Color.fromARGB(255, 120, 5, 140)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: photos.isNotEmpty 
          ? [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: "Memory Lane",
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemoryLaneScreen(photos: photos),
                    ),
                  );
                },
              ),
            ]
          : null,
      ),
      body: photos.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_album_outlined, 
                  size: 100.sp, 
                 // color: Colors.pink[200]
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Memories Yet',
                  style: TextStyle(
                    fontSize: 22.sp, 
                  //  color: Colors.pink[300],
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Tap the camera button to start your photo diary',
                  style: TextStyle(
                    fontSize: 16.sp, 
                 //   color: Colors.pink[200]
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              return ListView.builder(
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h, 
                      horizontal: 15.w
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26, 
                                blurRadius: 6, 
                                spreadRadius: 2, 
                                offset: Offset(3, 5)
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          photos[index].isexpanded = !photos[index].isexpanded;
                                        });
                                      },
                                      onDoubleTap: () => Navigator.push(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context) => PhotoDetailsScreen(
                                            image: photos[index].image,
                                            caption: photos[index].caption,
                                            entry: photos[index].entry,
                                            date: photos[index].date,
                                            onCaptionEdit: () => _editCaption(index),
                                            onEntryEdit: () => _editEntry(index),
                                          ),
                                        ),
                                      ),
                                      child: _buildImageWidget(photos[index].image),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete, 
                                        color: Colors.white.withOpacity(0.7),
                                        size: 30.sp,
                                      ),
                                      onPressed: () => _deleteEntry(index),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    photos[index].isexpanded = !photos[index].isexpanded;
                                  });
                                },
                                onDoubleTap: () => _editCaption(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    photos[index].caption, 
                                    style: TextStyle(
                                      fontSize: 18.sp, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: 'Cursive'
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (photos[index].isexpanded)
                          GestureDetector(
                            onDoubleTap: () => _editEntry(index),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${DateFormat('MMMM d, yyyy').format(photos[index].date)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.pink[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    photos[index].entry,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
       // backgroundColor: photos.isEmpty 
         // ? const Color.fromARGB(255, 227, 17, 87) 
          //: null,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    return Image(
      image: imagePath.startsWith('assets/') 
        ? AssetImage(imagePath)
        : FileImage(File(imagePath)) as ImageProvider,
      width: double.infinity,
      height: 300.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          width: double.infinity,
          height: 300.h,
          color: Colors.grey[300],
          child: Center(
            child: Text(
              'Failed to load image',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        );
      },
    );
  }
}

class PhotoDetailsScreen extends StatelessWidget {
  final String image;
  final String caption;
  final String entry;
  final DateTime date;
  final VoidCallback? onCaptionEdit;
  final VoidCallback? onEntryEdit;

  const PhotoDetailsScreen({
    required this.image, 
    required this.caption, 
    required this.entry, 
    required this.date,
    this.onCaptionEdit,
    this.onEntryEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📷 Photo Details", style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 24.sp),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Edit Details", style: TextStyle(fontSize: 18.sp)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Edit Caption', style: TextStyle(fontSize: 16.sp)),
                          onTap: () {
                            Navigator.pop(context);
                            onCaptionEdit?.call();
                          },
                        ),
                        ListTile(
                          title: Text('Edit Entry', style: TextStyle(fontSize: 16.sp)),
                          onTap: () {
                            Navigator.pop(context);
                            onEntryEdit?.call();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 350.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image(
                        image: image.startsWith('assets/') 
                          ? AssetImage(image)
                          : FileImage(File(image)) as ImageProvider,
                        width: 350.w,
                        height: 350.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 350.w,
                            height: 350.h,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red, fontSize: 14.sp),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            caption,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            DateFormat('MMMM d, yyyy').format(date),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            entry,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryLaneScreen extends StatelessWidget {
  final List<PhotoEntry> photos;

  const MemoryLaneScreen({required this.photos, super.key});

  @override
  Widget build(BuildContext context) {
    final sortedPhotos = List<PhotoEntry>.from(photos)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "📖 Memory Lane",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 108, 54, 150),
        elevation: 5,
        shadowColor: const Color.fromARGB(255, 121, 84, 240),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 127, 88, 206),
                const Color.fromARGB(255, 93, 3, 109)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: sortedPhotos.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off, 
                  size: 80.sp, 
                  color: Colors.purple[200]
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Memories to Display',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[300],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Add some photos to your diary first',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.purple[200],
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Vertical Timeline Line
                Positioned(
                  left: 10.w, 
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5.w,
                    color: Colors.purpleAccent.withOpacity(0.5), 
                  ),
                ),
                ListView.builder(
                  itemCount: sortedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = sortedPhotos[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0 || !isSameDay(photo.date, sortedPhotos[index - 1].date))
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 25.w),
                            child: Text(
                              DateFormat('MMMM d, yyyy').format(photo.date),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 26, 29, 184),
                              ),
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline Indicator (Dot)
                            Container(
                              margin: EdgeInsets.only(left: 6.w, right: 12.w, top: 8.h),
                              width: 12.w,
                              height: 12.h,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 131, 4, 205),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoDetailsScreen(
                                        image: photo.image,
                                        caption: photo.caption,
                                        entry: photo.entry,
                                        date: photo.date,
                                        onCaptionEdit: null,
                                        onEntryEdit: null,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center( 
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image(
                                              image: photo.image.startsWith('assets/')
                                                  ? AssetImage(photo.image)
                                                  : FileImage(File(photo.image)) as ImageProvider,
                                              height: 300.h,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 80.w,
                                                  height: 80.h,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image_not_supported),
                                                );
                                              },
                                            ),
                                          )
                                        ),
                                        SizedBox(height: 12.h),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              photo.caption,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              photo.entry.length > 50
                                                  ? '${photo.entry.substring(0, 50)}...'
                                                  : photo.entry,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}