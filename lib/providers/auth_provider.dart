import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Synchronous check first (handles edge case where authStateChanges never fires)
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      state = const AsyncValue.data(null);
    } else {
      fetchUserData(currentUser.uid);
    }

    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = const AsyncValue.data(null);
      } else {
        await fetchUserData(firebaseUser.uid);
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!, uid);
        state = AsyncValue.data(userModel);
      } else {
        // Fallback or if document doesn't exist yet
        state = AsyncValue.data(UserModel(
          id: uid,
          name: _auth.currentUser?.displayName ?? 'User',
          email: _auth.currentUser?.email ?? '',
          photoUrl: _auth.currentUser?.photoURL ?? '',
          joinedAt: DateTime.now(),
        ));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        // Update Firebase display name
        await firebaseUser.updateDisplayName(name);

        final newUser = UserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          photoUrl: '',
          joinedAt: DateTime.now(),
          streak: 1, // Start with 1 day streak
          currentLevel: 'Beginner',
        );

        // Store user in Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        
        state = AsyncValue.data(newUser);
      } else {
        throw Exception("User registration failed.");
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await fetchUserData(credential.user!.uid);
      } else {
        throw Exception("User login failed.");
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user document already exists in Firestore
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        UserModel userModel;
        
        if (!doc.exists) {
          // Create new user profile if first time Google login
          userModel = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL ?? '',
            joinedAt: DateTime.now(),
            streak: 1,
            currentLevel: 'Beginner',
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());
        } else {
          userModel = UserModel.fromMap(doc.data()!, firebaseUser.uid);
        }

        state = AsyncValue.data(userModel);
      } else {
        throw Exception("Google Sign-in failed.");
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
