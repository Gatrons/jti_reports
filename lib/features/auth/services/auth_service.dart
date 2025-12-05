import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jti_reports/core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ============ EMAIL/PASSWORD REGISTRATION ============
  Future<UserModel?> daftarUser({
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Gagal membuat user');

      // Kirim email verifikasi
      await user.sendEmailVerification();

      // Buat user model dengan emailVerified = false (sementara)
      final userModel = UserModel(
        uid: user.uid,
        name: namaLengkap,
        email: email,
        role: AppConstants.defaultUserRole,
        emailVerified: false, // Awalnya false, akan di-update nanti
        createdAt: Timestamp.now(),
        provider: 'email',
      );

      await _simpanDataUser(user.uid, userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  // ============ VERIFIKASI EMAIL ============
  Future<void> periksaDanUpdateVerifikasiEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Reload user untuk mendapatkan status verifikasi terbaru
      await user.reload();
      final userUpdated = _auth.currentUser;

      if (userUpdated != null && userUpdated.emailVerified) {
        // Update status di Firestore jika email sudah terverifikasi
        await _updateUserData(user.uid, {
          'emailVerified': true,
          'emailVerifiedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Gagal memeriksa verifikasi email: $e');
    }
  }

  // ============ GET USER DATA DENGAN VERIFIKASI REAL-TIME ============
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        final userModel = UserModel.fromMap(uid, doc.data()!);

        // Periksa status verifikasi terbaru dari Firebase Auth
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.reload();
          final isEmailVerified = currentUser.emailVerified;

          // Update di Firestore jika status berbeda
          if (isEmailVerified != userModel.emailVerified) {
            await _updateUserData(uid, {
              'emailVerified': isEmailVerified,
              if (isEmailVerified) 'emailVerifiedAt': Timestamp.now(),
            });
          }

          return userModel.copyWith(emailVerified: isEmailVerified);
        }

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data user: $e');
    }
  }

  // ============ EMAIL/PASSWORD SIGN IN DENGAN VERIFIKASI ============
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Gagal login');

      // Periksa dan update status verifikasi email
      await periksaDanUpdateVerifikasiEmail();

      final userData = await getUserData(user.uid);
      return userData;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  // ============ GOOGLE SIGN IN ============
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception(AppConstants.errorGoogleSignInCancelled);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('Gagal login dengan Google');

      // Untuk Google Sign In, email sudah terverifikasi otomatis
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      UserModel userModel;

      if (userDoc.exists) {
        userModel = UserModel.fromMap(user.uid, userDoc.data()!);

        // Update data jika diperlukan
        final updates = <String, dynamic>{};
        if (user.photoURL != userModel.photoURL) {
          updates['photoURL'] = user.photoURL;
        }
        // Pastikan emailVerified true untuk Google Sign In
        if (!userModel.emailVerified) {
          updates['emailVerified'] = true;
          updates['emailVerifiedAt'] = Timestamp.now();
        }

        if (updates.isNotEmpty) {
          await _updateUserData(user.uid, updates);
          userModel = userModel.copyWith(
            photoURL: user.photoURL,
            emailVerified: true,
          );
        }
      } else {
        // User baru dengan Google - email sudah terverifikasi
        userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? googleUser.displayName ?? 'User',
          email: user.email ?? googleUser.email,
          role: AppConstants.defaultUserRole,
          emailVerified: true, // Google Sign In otomatis terverifikasi
          createdAt: Timestamp.now(),
          photoURL: user.photoURL ?? googleUser.photoUrl,
          provider: 'google',
        );

        await _simpanDataUser(user.uid, userModel.toMap());
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login dengan Google: $e');
    }
  }

  // ============ KIRIM ULANG EMAIL VERIFIKASI ============
  Future<void> kirimUlangEmailVerifikasi() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Gagal mengirim ulang email verifikasi: $e');
    }
  }

  // ============ SIGN OUT ============
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }

  // ============ PASSWORD RESET ============
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat reset password: $e');
    }
  }

  // ============ USER MANAGEMENT ============
  Future<bool> isUserAdmin(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?.role == AppConstants.adminRole;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {...data, 'updatedAt': Timestamp.now()},
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update profil: $e');
    }
  }

  // ============ STREAMS ============
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists) {
            final userModel = UserModel.fromMap(uid, snapshot.data()!);

            // Periksa status verifikasi real-time
            final currentUser = _auth.currentUser;
            if (currentUser != null) {
              await currentUser.reload();
              final isEmailVerified = currentUser.emailVerified;

              // Update jika status berbeda
              if (isEmailVerified != userModel.emailVerified) {
                await _updateUserData(uid, {
                  'emailVerified': isEmailVerified,
                  if (isEmailVerified) 'emailVerifiedAt': Timestamp.now(),
                });
              }

              return userModel.copyWith(emailVerified: isEmailVerified);
            }

            return userModel;
          }
          return null;
        });
  }

  // ============ HELPER METHODS ============
  Future<void> _simpanDataUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(data);
  }

  Future<void> _updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  // ============ CURRENT USER INFO ============
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  String? get currentUserId => _auth.currentUser?.uid;

  // Method untuk mendapatkan status verifikasi real-time
  Future<bool> get isEmailVerified async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }
}
