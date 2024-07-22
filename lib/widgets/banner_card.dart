import 'package:flutter/material.dart';

class BannerCard extends StatelessWidget {
  final String imageAsset;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const BannerCard({
    Key? key,
    required this.imageAsset,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              imageAsset,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              padding: const EdgeInsets.all(16.0),
              child:Container(
                height: 150,
                width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onPressed,
                        child: Text(buttonText,style: TextStyle(fontSize: 18),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, // Button color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
            ),
          ],
        ),
      ),
    );
  }
}