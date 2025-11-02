import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class TransportSelectorWidget extends StatelessWidget {
  const TransportSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final transports = ['Flight', 'Train', 'Bus', 'Car'];

    return PopupMenuButton<String>(
      icon: Icon(
        _getTransportIcon(appState.selectedTransport),
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Transport: ${appState.selectedTransport}',
      onSelected: (value) => appState.setTransport(value),
      itemBuilder: (context) => transports.map((transport) {
        return PopupMenuItem(
          value: transport,
          child: Row(
            children: [
              Icon(_getTransportIcon(transport), size: 20),
              const SizedBox(width: 12),
              Text(transport),
              if (transport == appState.selectedTransport) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getTransportIcon(String transport) {
    switch (transport) {
      case 'Flight': return Icons.flight;
      case 'Train': return Icons.train;
      case 'Bus': return Icons.directions_bus;
      case 'Car': return Icons.directions_car;
      default: return Icons.flight;
    }
  }
}
