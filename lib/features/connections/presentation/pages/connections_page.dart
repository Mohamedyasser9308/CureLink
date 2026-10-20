import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/patient_connection.dart';
import '../../data/services/connection_service.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key, required this.accountRole});

  final String accountRole;

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  final _service = ConnectionService();
  final _patientIdController = TextEditingController();
  late final String? _uid;
  late final Stream<List<PatientConnection>> _caregiverConnections;
  late final Stream<List<PatientConnection>> _patientConnections;
  bool _sending = false;
  final Set<String> _responding = {};

  bool get _canSend =>
      widget.accountRole == 'caregiver' || widget.accountRole == 'both';

  bool get _canReview =>
      widget.accountRole == 'patient' || widget.accountRole == 'both';

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _caregiverConnections = _uid == null || !_canSend
        ? const Stream<List<PatientConnection>>.empty()
        : _service.watchCaregiverConnections(_uid);
    _patientConnections = _uid == null || !_canReview
        ? const Stream<List<PatientConnection>>.empty()
        : _service.watchPatientConnections(_uid);
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final l10n = AppLocalizations.of(context)!;
    if (_sending) return;

    setState(() => _sending = true);
    try {
      await _service.requestPatientAccess(_patientIdController.text);
      _patientIdController.clear();
      _showMessage(l10n.connectionRequestSent);
    } catch (error) {
      _showMessage(_requestError(error, l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _requestError(Object error, AppLocalizations l10n) {
    if (error is ConnectionException) {
      return switch (error.code) {
        'patient_id_required' => l10n.enterPatientId,
        'patient_not_found' => l10n.patientIdNotFound,
        'cannot_connect_self' => l10n.cannotConnectSelf,
        'profile_name_missing' => l10n.connectionProfileNameMissing,
        'already_pending' => l10n.connectionAlreadyPending,
        'already_connected' => l10n.connectionAlreadyAccepted,
        _ => l10n.connectionRequestFailed,
      };
    }
    return l10n.connectionRequestFailed;
  }

  Future<void> _respond(
    PatientConnection connection, {
    required bool accept,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_responding.add(connection.id)) return;
    setState(() {});

    try {
      await _service.respondToRequest(connection: connection, accept: accept);
      _showMessage(accept ? l10n.connectionAccepted : l10n.connectionRejected);
    } catch (_) {
      _showMessage(l10n.connectionRequestFailed);
    } finally {
      _responding.remove(connection.id);
      if (mounted) setState(() {});
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_uid == null) {
      return AppScaffold(
        title: l10n.connectionManagementTitle,
        body: Center(child: Text(l10n.profileSignInAgain)),
      );
    }

    return AppScaffold(
      title: l10n.connectionManagementTitle,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            l10n.connectionManagementSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_canSend) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _patientIdController,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.patientId,
                hintText: l10n.enterPatientId,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              onSubmitted: (_) => _sendRequest(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _sendRequest,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_outlined),
                label: Text(l10n.sendConnectionRequest),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, l10n.yourConnectionRequests),
            const SizedBox(height: 8),
            _connectionsList(stream: _caregiverConnections, incoming: false),
          ],
          if (_canReview) ...[
            if (_canSend) const SizedBox(height: 24),
            _sectionTitle(context, l10n.incomingConnectionRequests),
            const SizedBox(height: 8),
            _connectionsList(stream: _patientConnections, incoming: true),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _connectionsList({
    required Stream<List<PatientConnection>> stream,
    required bool incoming,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<PatientConnection>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.connectionLoadFailed),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final connections = snapshot.data!
          ..sort((a, b) => a.id.compareTo(b.id));
        if (connections.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.noConnectionRequests),
          );
        }

        return Column(
          children: [
            for (final connection in connections)
              _connectionCard(connection, incoming: incoming),
          ],
        );
      },
    );
  }

  Widget _connectionCard(
    PatientConnection connection, {
    required bool incoming,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPending = connection.status == 'pending';
    final title = incoming
        ? connection.caregiverName
        : '${l10n.connectionPatientId}: ${connection.patientUniqueId}';
    final statusText = switch (connection.status) {
      'accepted' => l10n.connectionAcceptedStatus,
      'rejected' => l10n.connectionRejectedStatus,
      _ => incoming ? l10n.connectionPendingStatus : l10n.waitingForApproval,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    incoming
                        ? Icons.volunteer_activism_outlined
                        : Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(statusText),
                    ],
                  ),
                ),
                if (connection.status == 'accepted')
                  Icon(
                    Icons.verified_outlined,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            if (incoming && isPending) ...[
              const SizedBox(height: 8),
              Text(l10n.connectionPermissionStatement),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _responding.contains(connection.id)
                          ? null
                          : () => _respond(connection, accept: false),
                      child: Text(l10n.rejectConnection),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _responding.contains(connection.id)
                          ? null
                          : () => _respond(connection, accept: true),
                      child: _responding.contains(connection.id)
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.acceptConnection),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
