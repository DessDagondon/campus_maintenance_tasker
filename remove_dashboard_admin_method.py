from pathlib import Path
path = Path('lib/screens/dashboard_screen.dart')
text = path.read_text(encoding='utf-8')
start = text.find('  Widget _buildAdminSettings(')
end = text.find('\n\nclass _SidebarButton', start)
if start == -1 or end == -1:
    raise RuntimeError('markers not found')
new_text = text[:start] + text[end:]
path.write_text(new_text, encoding='utf-8')
print('removed old admin method')
