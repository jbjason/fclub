import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/util/my_dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AuthTopText extends StatefulWidget {
  const AuthTopText({
    super.key,
    required this.pickedImage,
    required this.isLogin,
  });
  final bool isLogin;
  final Function(File) pickedImage;
  @override
  State<AuthTopText> createState() => _AuthTopTextState();
}

class _AuthTopTextState extends State<AuthTopText> {
  File? _image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isLogin) ...[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'sign_in'.tr(),
                    style: GoogleFonts.fjallaOne(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    'auth_tagline'.tr(),
                    style: GoogleFonts.fjallaOne(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
        ] else ...[
          // circle avatar
          _circleAvatar(),
          // image source icon like Camera & Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageIcon(ImageSource.camera, Icons.camera_alt_sharp),
              const Text('Add image', style: TextStyle(color: Colors.white70)),
              _imageIcon(ImageSource.gallery, Icons.image),
            ],
          ),
        ],
      ],
    );
  }

  CircleAvatar _circleAvatar() {
    return CircleAvatar(
      radius: 35,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: MyDimens.loginGradient,
        ),
        child: _image == null
            ? Container()
            : CircleAvatar(radius: 33.5, backgroundImage: FileImage(_image!)),
      ),
    );
  }

  IconButton _imageIcon(ImageSource source, IconData icon) {
    return IconButton(
      onPressed: () => _pickImage(source),
      icon: Icon(icon, color: Colors.white70),
    );
  }

  void _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(
      source: source,
      imageQuality: 40,
      maxHeight: 150,
      maxWidth: 150,
    );
    if (img == null) return;
    setState(() => _image = File(img.path));
    widget.pickedImage(_image!);
  }
}
