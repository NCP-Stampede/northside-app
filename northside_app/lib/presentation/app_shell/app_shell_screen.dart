// In file: lib/presentation/app_shell/app_shell_screen.dart

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          // CHANGED: The Container now has a boxShadow property.
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              // CHANGED: Using a slightly off-white color for better depth.
              color: const Color(0xFFF9F9F9).withOpacity(0.90),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              // NEW: Added a subtle shadow to the navigation bar.
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem('Home', 0),
                _buildNavItem('Athletics', 1),
                _buildNavItem('Attendance', 2),
                _buildNavItem('Grades', 3),
                _buildProfileNavIcon(4),
              ],
            ),
          ),
        ),
      ),
    );
  }
