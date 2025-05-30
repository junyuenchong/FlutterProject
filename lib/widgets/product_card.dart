import 'dart:io';

import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name; // Name of the product
  final String imageUrl; // URL for the product image
  final double price; // Price of the product
  final String offerTag; // A tag for any special offer or discount
  final Function onTap; // Function to handle tap events

  const ProductCard(
      {super.key,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.offerTag,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Makes the card tappable
      onTap: () {
        onTap(); // Executes the onTap function when the card is tapped
      },
      child: Card(
        elevation: 2, // Adds shadow to the card for depth
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Adds padding around the content
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns content to the start (left)
            children: [
              // Check if the imageUrl is a file path or a URL
              imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl, // Loads the image from the provided URL
                      fit: BoxFit.cover, // Ensures the image covers the available space
                      width: double.maxFinite, // Makes the image take full width
                      height: 120, // Fixed height for the image
                    )
                  : Image.file(
                      File(imageUrl), // Loads the image from the local file path
                      fit: BoxFit.cover, // Ensures the image covers the available space
                      width: double.maxFinite, // Makes the image take full width
                      height: 120, // Fixed height for the image
                    ),
              const SizedBox(
                height: 9, // Adds vertical space between elements
              ),
              Text(
                name, // Displays the product name
                style:
                    const TextStyle(fontSize: 16), // Sets the font size for the name
                overflow:
                    TextOverflow.ellipsis, // Truncates the text if it overflows
              ),
              const SizedBox(
                height: 9, // Adds vertical space between elements
              ),
              Text(
                'Rs : $price', // Displays the product price with currency
                style:
                    const TextStyle(fontSize: 16), // Sets the font size for the price
                overflow:
                    TextOverflow.ellipsis, // Truncates the text if it overflows
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8), // Adds padding inside the container
                decoration: BoxDecoration(
                  color: Colors.green, // Background color for the offer tag
                  borderRadius:
                      BorderRadius.circular(4), // Rounded corners for the tag
                ),
                child: Text(
                  offerTag, // Displays the offer tag text
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12), // Sets the style for the offer text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
