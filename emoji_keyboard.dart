import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antmap_mvp/utils/emojis.dart';

class EmojiKeyboard extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final Function() onClose;
  final bool isDarkMode;
  
  const EmojiKeyboard({
    super.key,
    required this.onEmojiSelected,
    required this.onClose,
    this.isDarkMode = false,
  });
  

  @override
  State<EmojiKeyboard> createState() => _EmojiKeyboardState();
}

class _EmojiKeyboardState extends State<EmojiKeyboard> {
  final TextEditingController _searchController = TextEditingController(); 
  int _selectedCategoryIndex = 0;
  List<String> _searchResults = [];
  List<String> _recentEmojis = [];
  static const String _recentEmojisKey = 'recent_emojis';
  static const int _maxRecentEmojis = 30;
  bool _isSearchMode = false;
  bool _isKeyboardVisible = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentEmojis();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }
  

  void clearSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      setState(() {
        _isKeyboardVisible = false;
      });
    }
  }
  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _searchFocusNode.hasFocus;
    });
  }

  Future<void> _loadRecentEmojis() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentList = prefs.getStringList(_recentEmojisKey);
      if (recentList != null) {
        setState(() {
          _recentEmojis = recentList;
        });
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
      debugPrint('Erreur lors du chargement des emojis récents: $e');
    }
  }

  Future<void> _saveRecentEmoji(String emoji) async {
    if (_recentEmojis.contains(emoji)) {
      _recentEmojis.remove(emoji);
    }
    _recentEmojis.insert(0, emoji);
    
    if (_recentEmojis.length > _maxRecentEmojis) {
      _recentEmojis = _recentEmojis.sublist(0, _maxRecentEmojis);
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentEmojisKey, _recentEmojis);
    } catch (e) {
      // Gérer l'erreur silencieusement
      debugPrint('Erreur lors de la sauvegarde des emojis récents: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isSearchMode = true;
    });
    
    // Rechercher dans toutes les catégories
    final allEmojis = [
      ...Emojis.smileyEmojis,
      ...Emojis.animalEmojis,
      ...Emojis.foodEmojis,
      ...Emojis.sportEmojis,
      ...Emojis.transportEmojis,
      ...Emojis.objectEmojis,
      ...Emojis.symbolEmojis,
      ...Emojis.flagEmojis,
    ];
    
    // Pour une recherche basique, on pourrait simplement filtrer
    // Dans une app réelle, vous pourriez associer des mots-clés à chaque emoji
    setState(() {
      _searchResults = allEmojis;
    });
  }

  List<String> _getCurrentEmojis() {
    if (_isSearchMode) {
      return _searchResults;
    }
    
    switch (_selectedCategoryIndex) {
      case 0:
        return _recentEmojis;
      case 1:
        return Emojis.smileyEmojis;
      case 2:
        return Emojis.animalEmojis;
      case 3:
        return Emojis.foodEmojis;
      case 4:
        return Emojis.sportEmojis;
      case 5:
        return Emojis.transportEmojis;
      case 6:
        return Emojis.objectEmojis;
      case 7:
        return Emojis.symbolEmojis;
      case 8:
        return Emojis.flagEmojis;
      default:
        return Emojis.smileyEmojis;
    }
  }

  void _handleEmojiSelected(String emoji) async {
    widget.onEmojiSelected(emoji);
    await _saveRecentEmoji(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
            border: Border(
              top: BorderSide(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFF171717).withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          height: 300,
          child: Column(
            children: [
              _buildSearchBar(),
              _buildCategoryBar(),
              Expanded(
                child: _isKeyboardVisible ? _buildSearchResults() : _buildEmojiGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.grey[900]
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search emojis',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.grey[600],
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                setState(() {
                  _isSearchMode = false;
                  _isKeyboardVisible = false;
                });
                widget.onClose();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: widget.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Résultats pour "${_searchController.text}"',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.0,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final emoji = _searchResults[index];
                return GestureDetector(
                  onTap: () {
                    _handleEmojiSelected(emoji);
                    _searchFocusNode.unfocus();
                    setState(() {
                      _isKeyboardVisible = false;
                    });
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 35,
                        fontFamily: 'AppleColorEmoji',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryIcon(int index, bool isSelected) {
    // Pour cet exemple, j'utilise des icônes de base Flutter
    // mais vous pourriez les remplacer par vos images d'asset
    if (index == 0) {
      return Icon(
        Icons.access_time, 
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 1) {
      return Icon(
        Icons.emoji_emotions,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 2) {
      return Icon(
        Icons.pets,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 3) {
      return Icon(
        Icons.cake,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 4) {
      return Icon(
        Icons.sports_soccer,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 5) {
      return Icon(
        Icons.directions_car,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 6) {
      return Icon(
        Icons.lightbulb,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else if (index == 7) {
      return Icon(
        Icons.music_note,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    } else {
      return Icon(
        Icons.flag,
        color: isSelected ? const Color(0xFFE67E22) : Colors.white,
        size: 24,
      );
    }
  }

  Widget _buildCategoryBar() {
    // Si nous sommes en mode recherche et que le clavier est visible, nous n'affichons pas la barre de catégories
    if (_isKeyboardVisible) {
      return Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tapez pour rechercher des emojis',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${_searchResults.length} trouvé(s)',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white54 : Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
    // Sinon, nous affichons la barre de catégories normale
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Emojis.categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFF1F1F1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              
              child: Center(
                child: Row(
                  children: [
                    _categoryIcon(index, isSelected),
                  ],
                ),
              ),
            ),
          );
        },
              ),
    );
  }

  Widget _buildEmojiGrid() {
    final emojis = _getCurrentEmojis();
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1.0,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return GestureDetector(
          onTap: () => _handleEmojiSelected(emoji),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 35, 
                fontFamily: 'AppleColorEmoji',
              ),
            ),
          ),
        );
      },
    );
  }
}

