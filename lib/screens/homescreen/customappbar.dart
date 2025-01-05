import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/signinpage.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final String? userAvatarUrl;
  final VoidCallback? onSettingsTap;

  const CustomAppBar({
    Key? key,
    this.notificationCount = 0,
    this.userAvatarUrl,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Widget _buildUserAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellowAccent,
            image: userAvatarUrl != null
                ? DecorationImage(
              image: NetworkImage(userAvatarUrl!),
              fit: BoxFit.cover,
            )
                : null,
          ),
        ),
        if (userAvatarUrl == null)
          const Icon(
            CupertinoIcons.person_fill,
            color: Colors.black54,
          ),
      ],
    );
  }

  Widget _buildUserGreeting(BuildContext context, String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Hi!",
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          userName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onSettingsTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          icon: const Icon(CupertinoIcons.settings_solid),
          color: Theme.of(context).iconTheme.color,
          tooltip: 'Settings',
        ),
        if (notificationCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildUserAvatar(),
              const SizedBox(width: 8),
              FutureBuilder<String?>(
                future: getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final userName = snapshot.data ?? 'Guest';
                  return _buildUserGreeting(context, userName);
                },
              ),
            ],
          ),
          _buildSettingsButton(context),
        ],
      ),
    );
  }
}
