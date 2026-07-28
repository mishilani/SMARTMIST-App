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
    return Scaffold(
      appBar: showBackButton
          ? AppBar(
              toolbarHeight: 70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 25, top: 20),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  iconSize: 20,
                  color: const Color(0xFF2E3A46),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
