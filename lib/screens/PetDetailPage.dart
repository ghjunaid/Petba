import 'package:flutter/material.dart';
import 'package:petba_new/chat/Model/ChatModel.dart';
import 'package:petba_new/chat/Model/Messagemodel.dart';
import 'package:petba_new/chat/screens/Individualpage.dart';
import 'package:petba_new/chat/socket_sevice.dart';
import 'package:petba_new/models/adoption.dart';
import 'package:petba_new/providers/Config.dart';
import 'package:petba_new/services/user_data_service.dart';

class PetDetailPage extends StatelessWidget {
  final AdoptionPet pet;

  PetDetailPage({required this.pet});

  String _calculateAge(String dob) {
    try {
      final DateTime birthDate = DateTime.parse(dob);
      final DateTime now = DateTime.now();
      final int years = now.year - birthDate.year;
      final int months = now.month - birthDate.month;

      if (years > 0) {
        return '$years year${years > 1 ? 's' : ''} old';
      } else if (months > 0) {
        return '$months month${months > 1 ? 's' : ''} old';
      } else {
        return 'Less than 1 month old';
      }
    } catch (e) {
      return 'Age unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF2d2d2d),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pet image
            Container(
              width: double.infinity,
              height: 300,
              child: pet.img1.isNotEmpty
                  ? Image.network(
                '$apiurl/${pet.img1}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade600,
                    child: Icon(
                      Icons.pets,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade600,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey.shade600,
                child: Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            // Pet details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF2d2d2d),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet name
                  Text(
                    pet.name.toLowerCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Pet type and location
                  Row(
                    children: [
                      Icon(Icons.pets, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        pet.animalName,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        pet.city,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Pet details in a row
                  Row(
                    children: [
                      // Sex
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sex:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pet.gender == 1 ? 'Male' : 'Female',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Age
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _calculateAge(pet.dob),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Breed
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Breed:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pet.breed,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // ID Information
                  Text(
                    'Pet ID: ${pet.adoptId}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Customer ID: ${pet.cId}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  SizedBox(height: 40),

                  // Adopt button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleAdoptRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Adopt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAdoptRequest(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Creating chat...',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );

      // Get current user data
      final userData = await UserDataService.getUserData();
      if (userData == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final currentUserId = userData['customer_id'] ?? userData['id'];
      print('Current User ID: $currentUserId');
      final currentUserName = '${userData['firstname']} ${userData['lastname']}';
      print('Current Nameee: $currentUserName');

      // Create UserModel for current user
      final currentUser = UserModel(
        id: currentUserId,
        name: currentUserName,
        email: userData['email'],
        phoneNumber: userData['telephone'] ?? '',
        location: pet.city,
        profileImageUrl: '',
        createdAt: DateTime.now(),
        token: userData['token'],
      );

      // Initialize socket service
      final socketService = SocketService.getInstance();


      // Store reference to created chat
      ChatModel? createdChatModel;
      String? conversationId;

      // Set up listeners for chat creation
      socketService.onNewChat = (chatData) {
        print('Chat creation response: $chatData');

        if (chatData.containsKey('conversationId')) {
          conversationId = chatData['conversationId'].toString();

          // Create chat model from response
          createdChatModel = ChatModel(
            name: pet.name,
            icon: "pet.svg",
            isGroup: false,
            time: DateTime.now().toString(),
            currentMessage: "Chat started for ${pet.name} adoption",
            id: pet.adoptId,
            ownerId: pet.cId,
            ownerName: chatData['ownerName'] ?? "Pet Owner",
            petName: pet.name,
            petBreed: pet.breed,
            petType: pet.animalName,
            petImageUrl: '$apiurl/${pet.img1}',
            isPetChat: true,
            adoptionId: pet.adoptId.toString(),
            conversationId: int.parse(conversationId!),
            senderId: currentUserId,
            receiverId: pet.cId,
            interestedUserId: currentUserId,
            interestedUserName: currentUserName,
          );
        }
      };

      // Connect to socket for chat list management
      socketService.connectForChatList(
        userId: currentUserId,
        onNewChat: socketService.onNewChat,
      );

      // Wait for socket connection
      await Future.delayed(Duration(seconds: 1));

      // Create or get chat via socket
      socketService.createOrGetChat(
        senderId: currentUserId,
        receiverId: pet.cId,
        adoptionId: pet.adoptId.toString(),
        petName: pet.name,
        petImageUrl: '$apiurl/${pet.img1}',
        petBreed: pet.breed,
        petType: pet.animalName,
        ownerName: "Pet Owner", // You might want to fetch actual owner name
        interestedUserName: currentUserName,
      );

      // Wait for chat creation response
      int attempts = 0;
      while (createdChatModel == null && conversationId == null && attempts < 10) {
        await Future.delayed(Duration(milliseconds: 500));
        attempts++;
      }

      Navigator.pop(context); // Close loading dialog

      if (createdChatModel != null && conversationId != null) {
        socketService.sendMessage(
          message: "Hi! I'm interested in adopting ${pet.name}. Can we discuss the details?",
          sourceId: currentUserId,
          targetId: pet.cId,
          senderName: currentUserName,
          receiverName: "Pet Owner",
          adoptionId: pet.adoptId.toString(),
          petName: pet.name,
        );
        // Navigate to individual chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Individualpage(
              chatModel: createdChatModel!,
              sourchat: ChatModel(
                name: currentUser.name,
                icon: "person.svg",
                isGroup: false,
                time: DateTime.now().toString(),
                currentMessage: "",
                id: currentUser.id,
                ownerId: currentUser.id,
                ownerName: currentUser.name,
              ),
              currentUser: currentUser,
              conversationId: int.parse(conversationId!),
            ),
          ),
        );
      } else {
        // Fallback: Create chat model manually and navigate
        final fallbackChatModel = ChatModel(
          name: pet.name,
          icon: "pet.svg",
          isGroup: false,
          time: DateTime.now().toString(),
          currentMessage: "Chat started for ${pet.name} adoption",
          id: pet.adoptId,
          ownerId: pet.cId,
          ownerName: "Pet Owner",
          petName: pet.name,
          petBreed: pet.breed,
          petType: pet.animalName,
          petImageUrl: '$apiurl/${pet.img1}',
          isPetChat: true,
          adoptionId: pet.adoptId.toString(),
          conversationId: DateTime.now().millisecondsSinceEpoch,
          senderId: currentUserId,
          receiverId: pet.cId,
          interestedUserId: currentUserId,
          interestedUserName: currentUserName,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Individualpage(
              chatModel: fallbackChatModel,
              sourchat: ChatModel(
                name: currentUser.name,
                icon: "person.svg",
                isGroup: false,
                time: DateTime.now().toString(),
                currentMessage: "",
                id: currentUser.id,
                ownerId: currentUser.id,
                ownerName: currentUser.name,
              ),
              currentUser: currentUser,
              conversationId: fallbackChatModel.conversationId!,
            ),
          ),
        );
      }

    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      print('Exception in _handleAdoptRequest: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}