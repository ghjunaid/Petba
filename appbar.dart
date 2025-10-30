// import 'package:flutter/material.dart';
// import 'package:petba_new/providers/Constants.dart';

// class AppBarWidget extends StatelessWidget {
//   AppBarWidget({required this.title, this.width = 120});
//   final String title;
//   final double width;
//   @override
//   Widget build(BuildContext context) {
//     final windowWidth = MediaQuery.of(context).size.width;
//     return Container(
//       height: 55.0,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: kThemeColour.withOpacity(0.10),
//             blurRadius: 6.0,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       alignment: Alignment.centerLeft,
//       child: InkWell(
//         child: Container(
//           width: width,
//           height: 40.0,
//           padding: EdgeInsets.symmetric(horizontal: windowWidth * 0.03),
//           child: Row(
//             children: [
//               Icon(Icons.chevron_left, color: kThemeColour),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         onTap: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }
