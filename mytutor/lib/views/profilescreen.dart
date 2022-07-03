import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mytutor/views/loginscreen.dart';
import 'package:ndialog/ndialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<User> userList = <User>[];
  String titlecenter = "Loading...";
  var _image;
  late double screenHeight, screenWidth, resWidth;
  var val = 50;
  Random random = Random();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name.toString();
    _phoneController.text = widget.user.phone.toString();
    _addressController.text = widget.user.address.toString();
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tutor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight / 3,
              child: SizedBox(
                width: resWidth,
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            //onTap: () => {_updateImageDialog()},
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: CONSTANTS.server +
                                    '/mytutor/mobile/assets/users/${widget.user.id}.jpg' +
                                    "?v=$val",
                                fit: BoxFit.cover,
                                width: resWidth / 2,
                                placeholder: (context, url) =>
                                    const LinearProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name.toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  Text(" " + widget.user.email.toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  Text(" " + widget.user.phone.toString()),
                                ],
                              ),
                              Text(widget.user.address.toString()),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                child: SizedBox(
              width: resWidth,
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: const Center(
                          child: Text("PROFILE SETTINGS",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      )),
                  Expanded(
                      child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Update Name",
                            style: TextStyle(fontSize: 15)),
                        trailing: IconButton(
                            onPressed: () {
                              _updateNameDialog();
                            },
                            icon: const Icon(Icons.arrow_right)),
                      ),
                      const Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Update Phone Number",
                            style: TextStyle(fontSize: 15)),
                        trailing: IconButton(
                            onPressed: () {
                              _updatePhoneDialog();
                            },
                            icon: const Icon(Icons.arrow_right)),
                      ),
                      const Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text("Update Address",
                            style: TextStyle(fontSize: 15)),
                        trailing: IconButton(
                            onPressed: () {
                              _updateAddressDialog();
                            },
                            icon: const Icon(Icons.arrow_right)),
                      ),
                      const Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text("Change Password",
                            style: TextStyle(fontSize: 15)),
                        trailing: IconButton(
                            onPressed: () {
                              _changePasswordDialog();
                            },
                            icon: const Icon(Icons.arrow_right)),
                      ),
                      const Divider(
                        height: 2,
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text("Logout",
                            style: TextStyle(fontSize: 15)),
                        trailing: IconButton(
                            onPressed: () {
                              _logoutDialog();
                            },
                            icon: const Icon(Icons.arrow_right)),
                      ),
                    ],
                  ))
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  void _updateNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text(
                  "Update New Name?",
                  style: TextStyle(),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      String newname = _nameController.text;
                      _updateName(newname);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _changePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text(
                  "Change Password?",
                  style: TextStyle(),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _oldpasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Old Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _newpasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      String newpassword = _newpasswordController.text;
                      _changePassword(newpassword);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _updatePhoneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text(
                  "Update New Phone Number?",
                  style: TextStyle(),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: const TextInputType.numberWithOptions(),
                      decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new phone';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      String newphone = _phoneController.text;
                      _updatePhone(newphone);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _updateAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text(
                  "Update New Home Address?",
                  style: TextStyle(),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      minLines: 5,
                      maxLines: 5,
                      controller: _addressController,
                      decoration: InputDecoration(
                          labelText: 'Home Address',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new home address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      String newaddress = _addressController.text;
                      _updateAddress(newaddress);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _logoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text(
                  "Logout?",
                  style: TextStyle(),
                ),
                content: const Text("Are your sure"),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('email', '');
                      await prefs.setString('pass', '');
                      await prefs.setBool('remember', false);
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => LoginScreen()));
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _updateName(String newname) {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: const Text("Updating.."));
    progressDialog.show();
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/update_profile.php"),
        body: {
          "email": widget.user.email,
          "newname": newname,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
        setState(() {
          widget.user.name = newname;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
      }
    });
  }

  void _updatePhone(String newphone) {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: const Text("Updating.."));
    progressDialog.show();
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/update_profile.php"),
        body: {
          "email": widget.user.email,
          "newphone": newphone,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
        setState(() {
          widget.user.phone = newphone;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
      }
    });
  }

  void _updateAddress(String newaddress) {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: const Text("Updating.."));
    progressDialog.show();
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/update_profile.php"),
        body: {
          "email": widget.user.email,
          "newaddress": newaddress,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
        setState(() {
          widget.user.address = newaddress;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
      }
    });
  }

  void _changePassword(String newpassword) {
    ProgressDialog progressDialog =
        ProgressDialog(context, message: const Text("Updating.."));
    progressDialog.show();
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/update_profile.php"),
        body: {
          "email": widget.user.email,
          "newpassword": newpassword,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
        setState(() {
          widget.user.password = newpassword;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
      }
    });
  }

  /*_updateImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          _galleryPicker(),
                        },
                    icon: const Icon(Icons.browse_gallery),
                    label: const Text("Gallery")),
                TextButton.icon(
                    onPressed: () =>
                        {Navigator.of(context).pop(), _cameraPicker()},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera")),
              ],
            ));
      },
    );
  }

  _galleryPicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _cropImage();
    }
  }

  _cameraPicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _cropImage();
    }
  }*/

  /*Future<void> _cropImage() async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      _updateProfileImage(_image);
    }
  }*/

  /*void _updateProfileImage(image) {
    String base64Image = base64Encode(image!.readAsBytesSync());
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Uploading.."), title: null);
    progressDialog.show();
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/update_profile.php"),
        body: {
          "id": widget.user.id,
          "image": base64Image,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
        val = random.nextInt(1000);

        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        progressDialog.dismiss();
      }
    });
  }*/
}
