import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback showPromtScreen;
  const HomeScreen({super.key, required this.showPromtScreen});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Content for all  contents
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 73, 13, 13),
          Color.fromARGB(255, 105, 13, 13),
          Color.fromARGB(255, 37, 3, 3),
          Color.fromARGB(255, 26, 2, 2),
        ],
      )),

      //Column starts here
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First Expanded
          Expanded(
            flex: 3,
            //Padding around image in a stack
            child: Padding(
              padding: EdgeInsets.only(top: 40),

              // Stack starts here
              child: Stack(
                children: [
                  // Container for image
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/sonnet.png'),
                          fit: BoxFit.cover),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.4,
                              color: const Color(0xFFFFFFFF),
                            ),
                            shape: BoxShape.circle),
                        child: Container(
                          height: 110,
                          width: 110,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/sonnetlogo.png'),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Stack ends here
            ),
          ),

          // Second Expanded
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 15.0),

            //Column starts here
            child: Column(
              children: [
                //RichText
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(height: 1.3),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              'AI curated music playlist just for your mood \n',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFFFFFFFF),
                          )),
                      TextSpan(
                        text: '\n',
                        style: TextStyle(
                          height: 1,
                        ),
                      ),
                      TextSpan(
                          text: 'Get Started \n',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFFFFF),
                          ))
                    ],
                  ),
                ),

                // Container for arrow for forward in a Padding
                Padding(
                  padding: const EdgeInsets.only(top: 10),

                  // Container for arrow for forward in GestureDetector
                  child: GestureDetector(
                    onTap: widget.showPromtScreen,
                    // Container for arrow for forward
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFCCCC).withOpacity(0.3),
                          shape: BoxShape.circle),
                      child: Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF), shape: BoxShape.circle),

                        //Arrow forward centered
                        child: const Center(
                          //Arrow forward centered

                          child: Icon(
                            Icons.arrow_forward,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //Column starts here
          ))
        ],
      ),
      //Column ends here
    ));
  }
}
