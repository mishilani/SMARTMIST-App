import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.showBackButton = true,
  });

  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: showBackButton
          ? AppBar(
              toolbarHeight: screenHeight * 0.09,
              backgroundColor: Colors.transparent,
              elevation: 0,

              leading: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  top: screenHeight * 0.02,
                ),

                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),

                  iconSize: screenWidth * 0.05,

                  color: const Color(0xFF2E3A46),

                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          : null,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,

              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
