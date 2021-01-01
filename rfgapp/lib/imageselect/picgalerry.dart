import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rfgapp/providers/variables.dart';


/////////////////////////////////////////////////////////////////////

class GetPicFromGallery extends StatefulWidget {
  final String url;
  GetPicFromGallery(this.url);

  @override
  _GetPicFromGalleryState createState() => _GetPicFromGalleryState();
}

class _GetPicFromGalleryState extends State<GetPicFromGallery> {
  File _takenImage;
  bool _isLoading = false;

  Future<String> uploadImage(var imageFile) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(widget.url)
        .child(DateTime.now().toString() + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(imageFile);
      
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    Provider.of<Variables>(context, listen: false).storepath(url);
    return url;
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _takenImage = imageFile;
    });
    final appDir = await pPath.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  }

  @override
  void initState() {
    _takePicture();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<Variables>(context, listen: false).iamgepath = null;
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeery Pic'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                uploadImage(_takenImage)
                    .then((value) => Navigator.pop(context));
              })
        ],
      ),
      body: _takenImage == null
          ? Text('Choose Image', textAlign: TextAlign.center)
          : Stack(
              children: <Widget>[
                Image.file(
                  File(_takenImage.path),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                if(_isLoading == true)
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
    );
  }
}
