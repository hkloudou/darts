//ignore pendingRequest way

// import 'dart:async';
// import 'dart:collection';

// import 'package:doh/doh.dart';

// class DohPendingRequest extends LinkedListEntry<DohPendingRequest> {
//   // DohPendingRequest(
//   //     {required this.name, this.type = DohRecordType.A, this.controller});
//   DohPendingRequest(this.type, this.domainName, this.controller);

//   /// The domain name to look up via mDNS.
//   ///
//   /// For example, `www.google.com` to look up dns record on the remote doh service
//   /// domain.
//   String domainName = "";

//   /// The [DohRecordType] of the request.
//   final int type;

//   /// A StreamController managing the request.
//   final StreamController<DoHAnswer> controller;

//   /// The timer for the request.
//   Timer? timer;
// }

// /// Class for keeping track of pending lookups and processing incoming
// /// query responses.
// class DohLookupResolver {
//   final LinkedList<DohPendingRequest> _pendingRequests =
//       LinkedList<DohPendingRequest>();

//   /// Adds a request and returns a [Stream] of [ResourceRecord] responses.
//   Stream<T> addPendingRequest<T extends DoHAnswer>(
//       int type, String name, Duration timeout) {
//     final StreamController<T> controller = StreamController<T>();
//     final DohPendingRequest request = DohPendingRequest(type, name, controller);
//     final Timer timer = Timer(timeout, () {
//       request.unlink();
//       controller.close();
//     });
//     request.timer = timer;
//     _pendingRequests.add(request);
//     return controller.stream;
//   }

//   /// Parses [ResoureRecord]s received and delivers them to the appropriate
//   /// listener(s) added via [addPendingRequest].
//   void handleResponse(List<DoHAnswer> response) {
//     for (final DoHAnswer r in response) {
//       final int type = r.type;
//       String name = r.name.toLowerCase();
//       if (name.endsWith('.')) {
//         name = name.substring(0, name.length - 1);
//       }

//       bool responseMatches(DohPendingRequest request) {
//         String requestName = request.domainName.toLowerCase();
//         return requestName == name && request.type == type;
//       }

//       for (final DohPendingRequest pendingRequest in _pendingRequests) {
//         if (responseMatches(pendingRequest)) {
//           if (pendingRequest.controller.isClosed) {
//             return;
//           }
//           pendingRequest.controller.add(r);
//         }
//       }
//     }
//   }

//   /// Removes any pending requests and ends processing.
//   void clearPendingRequests() {
//     while (_pendingRequests.isNotEmpty) {
//       final DohPendingRequest request = _pendingRequests.first;
//       request.unlink();
//       request.timer?.cancel();
//       request.controller.close();
//     }
//   }
// }
