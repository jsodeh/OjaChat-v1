import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserCredential> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Set initial user role and profile
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'isUser': true,  // Default role
        'isVendor': false,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await credential.user?.updateDisplayName(name);
      
      return credential;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  Future<UserRole> getUserRole() async {
    if (_auth.currentUser == null) return UserRole();
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      return UserRole.fromMap(doc.data() ?? {});
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole();
    }
  }

  Stream<UserRole> userRoleStream() {
    if (_auth.currentUser == null) return Stream.value(UserRole());
    
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((doc) => UserRole.fromMap(doc.data() ?? {}));
  }
} 