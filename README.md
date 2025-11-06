# 📚 BookSwap App

## 🧾 Overview
The **BookSwap App** is a Flutter-based marketplace where students can list textbooks they wish to exchange and initiate swap offers with other users.  
The app integrates **Firebase Authentication**, **Cloud Firestore**, and **Firebase Storage** to enable real-time updates, image uploads, and secure user management.  

This project demonstrates mastery of:
- CRUD operations using Firebase (Create, Read, Update, Delete)
- State management with **Provider**
- Real-time synchronization of data
- Full mobile app structure: authentication, navigation, and dynamic UI updates

---

## 🚀 Features

### 🔑 Authentication
- Email and password sign-up, login, and logout using **Firebase Auth**.
- **Email verification** before users can access the app.
- Each user has a unique profile stored in Firestore.

### 📘 Book Listings (CRUD)
- **Create:** Users can post books with title, author, condition (New, Like New, Good, Used), and a cover image.
- **Read:** All listings appear in a shared “Browse Listings” feed.
- **Update:** Users can edit their own book listings.
- **Delete:** Users can delete their own listings.
- Book data is synced with **Firebase Firestore**, and images are stored in **Firebase Storage**.

### 🔁 Swap Functionality
- Users can send swap requests for any listed book.
- When a swap is initiated:
  - The listing moves to a “My Offers” section.
  - The state updates to **Pending**.
- Both sender and recipient see real-time updates in Firestore.

