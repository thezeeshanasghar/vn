import 'package:flutter/material.dart';

import '../models/assistant.dart';

class SidebarEntry {
  final String title;
  final IconData icon;

  const SidebarEntry({required this.title, required this.icon});
}

class PaSidebar extends StatelessWidget {
  final PaAssistant assistant;
  final List<SidebarEntry> entries;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const PaSidebar({
    super.key,
    required this.assistant,
    required this.entries,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final bool isSelected = index == selectedIndex;
                return _NavTile(
                  entry: entry,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent,
              size: 30,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'PA Portal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Assisting Dr. ${assistant.firstName} ${assistant.lastName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                assistant.firstName.isNotEmpty
                    ? assistant.firstName[0].toUpperCase()
                    : assistant.email.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistant.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Personal Assistant',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final SidebarEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.22) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  entry.icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.75),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.white.withOpacity(0.78),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

