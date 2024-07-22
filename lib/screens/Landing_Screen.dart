import 'package:flutter/material.dart';
import 'package:soundofmeme/screens/Login_Screen.dart';
import 'package:soundofmeme/screens/Prompt_Screen.dart';
import 'package:soundofmeme/screens/signup_screen.dart';
import 'package:soundofmeme/widgets/banner_card.dart';
import 'package:soundofmeme/widgets/meme_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(
    viewportFraction: 0.8,
  );
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _translateAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: constraints.maxHeight * 0.6,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 3,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return MemeCard(
                        imageAsset: 'assets/thumbnail${index + 1}.png',
                        audioUrl: 'https://cdn2.suno.ai/image_3fe1c3b1-2cca-4d27-8342-8053e6bb738f.jpeg?width=100',
                        title: 'Song ${index + 1}',
                        animationController: _animationController,
                        translateAnimation: _translateAnimation,
                        rotationAnimation: _rotationAnimation,
                      );
                    },
                  ),
                ),
                BannerCard(
                  imageAsset: 'assets/banner_image.png',
                  description: 'Create your own Sound of Memes using AI!',
                  buttonText: 'Get Started',
                  onPressed: () {
                    Navigator.pushNamed(context, PromptScreen.routeName);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.routeName);
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignupScreen.routeName);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
