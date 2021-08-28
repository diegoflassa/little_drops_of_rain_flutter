import 'dart:async';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
import 'package:little_drops_of_rain_flutter/l10n/messages_all.dart';

class AppLocalizations {

  String get pleaseUseTheMenuToNavigateBackInThisPage {
    return Intl.message('Please use the menu to navigate back in this page', name: 'pleaseUseTheMenuToNavigateBackInThisPage');
  }

  String get errorMeasuringSpeed {
    return Intl.message('There was a error during the measurement of the speed', name: 'errorMeasuringSpeed');
  }

  String get speedOk {
    return Intl.message('Your internet speed appears to be all right', name: 'speedOk');
  }

  String get slowSpeed {
    return Intl.message('It looks like your speed is slow. The data may take a while to load', name: 'slowSpeed');
  }

  String get testingSpeedConnection {
    return Intl.message('Testing speed connection...', name: 'testingSpeedConnection');
  }

  String get looksLikeItIsTakingALongTimeRetrying {
    return Intl.message('It looks like this operation is taking a long time. We will retry it. ', name: 'looksLikeItIsTakingALongTimeRetrying');
  }

  String get looksLikeItIsTakingALongTimeReload {
    return Intl.message('It looks like this operation is taking a long time. Try reloading the page.', name: 'looksLikeItIsTakingALongTimeReload');
  }

  String get looksLikeItIsTakingALongTimeReselectUniverse {
    return Intl.message('It looks like this operation is taking a long time. Try reselecting the universe', name: 'looksLikeItIsTakingALongTimeReselectUniverse');
  }

  String get unableToRetrieveLoginInformation {
    return Intl.message('Unable to retrieve login information', name: 'unableToRetrieveLoginInformation');
  }

  String get unableToSaveLoginInformation {
    return Intl.message('Unable to save login information', name: 'unableToSaveLoginInformation');
  }

  String get resetImage {
    return Intl.message('Reset', name: 'resetImage');
  }

  String get invalidLink {
    return Intl.message('Invalid Link:', name: 'invalidLink');
  }

  String get noUniverseFound {
    return Intl.message('Universe not found:', name: 'noUniverseFound');
  }

  String get noStoryFound {
    return Intl.message('Story not found:', name: 'noStoryFound');
  }

  String get noProductFound {
    return Intl.message('Product not found:', name: 'noProductFound');
  }

  String get pageTransitionTypeTitle {
    return Intl.message('Page Transition', name: 'pageTransitionTypeTitle');
  }

  String get pageTransitionTypeMessage {
    return Intl.message('Please choose the desired transition for the pages',
        name: 'pageTransitionTypeMessage');
  }

  String get pageTransition {
    return Intl.message('Page Transition', name: 'pageTransition');
  }

  String get cardToDetailsTransition {
    return Intl.message('Card to Details Transition',
        name: 'cardToDetailsTransition');
  }

  String get resetAnimationsSettings {
    return Intl.message('Reset animations settings',
        name: 'resetAnimationsSettings');
  }

  String get timeDilationValueTitle {
    return Intl.message('Time Dilation:', name: 'timeDilationValueTitle');
  }

  String get timeDilationValueMessage {
    return Intl.message(
        "Use this to slow down or up the application's animations",
        name: 'timeDilationValueMessage');
  }

  String get currentValue {
    return Intl.message('Current Value:', name: 'currentValue');
  }

  String get hyperSlow {
    return Intl.message('Hyper Slow (50.0x)', name: 'hyperSlow');
  }

  String get ultraSlow {
    return Intl.message('Ultra Slow (30.0x)', name: 'ultraSlow');
  }

  String get megaSlow {
    return Intl.message('Mega Slow (15.0x)', name: 'megaSlow');
  }

  String get verySlow {
    return Intl.message('Very Slow (10.0x)', name: 'verySlow');
  }

  String get slow {
    return Intl.message('Slow (5.0x)', name: 'slow');
  }

  String get normal {
    return Intl.message('Normal (1.0x)', name: 'normal');
  }

  String get fast {
    return Intl.message('Fast (0.5x)', name: 'fast');
  }

  String get veryFast {
    return Intl.message('Very Fast (0.1x)', name: 'veryFast');
  }

  String get fade {
    return Intl.message('Fade', name: 'fade');
  }

  String get scale {
    return Intl.message('Scale', name: 'scale');
  }

  String get slide {
    return Intl.message('Slide', name: 'slide');
  }

  String get size {
    return Intl.message('Size', name: 'size');
  }

  String get rotation {
    return Intl.message('Rotation', name: 'rotation');
  }

  String get product {
    return Intl.message('Product', name: 'product');
  }

  String get fadeThrough {
    return Intl.message('Fade Through', name: 'fadeThrough');
  }

  String get cardToDetailsTransitionTypeTitle {
    return Intl.message('Transition Types',
        name: 'cardToDetailsTransitionTypeTitle');
  }

  String get cardToDetailsTransitionTypeMessage {
    return Intl.message('Please choose the type of the transition',
        name: 'cardToDetailsTransitionTypeMessage');
  }

  String get currentTransition {
    return Intl.message('Current Transition:', name: 'currentTransition');
  }

  String get timeDilation {
    return Intl.message('Time Dilation', name: 'timeDilation');
  }

  String get animations {
    return Intl.message('Animations', name: 'animations');
  }

  String get compressLevelValueTitle {
    return Intl.message('Compression Level (from 1 to 9):',
        name: 'compressLevelValueTitle');
  }

  String get compressLevelValueMessage {
    return Intl.message(
        'Choose the compression level of the GZip, from 1 to 9, where the higher the number, the most the compression will be. It will only be applied to new downloaded files. If desired, clear the cache.',
        name: 'compressLevelValueMessage');
  }

  String get currentCompressionLevel {
    return Intl.message('Current Compression Level (from 1 to 9):',
        name: 'currentCompressionLevel');
  }

  String get compressionLevel {
    return Intl.message('Compression Level', name: 'compressionLevel');
  }

  String get enableCompression {
    return Intl.message('Enable Compression', name: 'enableCompression');
  }

  String get compressionExplanation {
    return Intl.message(
        'If enabled, compress the files prior to storing it. Note that previous downloaded images will be kept as is. If desired, clear the cache.',
        name: 'compressionExplanation');
  }

  String get itemsCount {
    return Intl.message('Items:', name: 'itemsCount');
  }

  String get universeUpdated {
    return Intl.message('Universe updated!', name: 'universeUpdated');
  }

  String get storyUpdated {
    return Intl.message('Story updated!', name: 'storyUpdated');
  }

  String get cacheSize {
    return Intl.message('Cache Size:', name: 'cacheSize');
  }

  String get productUpdated {
    return Intl.message('Product updated!', name: 'productUpdated');
  }

  String get resetCacheConfirmationTitle {
    return Intl.message('Reset Cache Settings',
        name: 'resetCacheConfirmationTitle');
  }

  String get resetCacheConfirmationMessage {
    return Intl.message(
        'Are you sure tha you want to reset the cache settings to its original values?',
        name: 'resetCacheConfirmationMessage');
  }

  String get resetCacheSettings {
    return Intl.message('Reset cache settings', name: 'resetCacheSettings');
  }

  String get notSet {
    return Intl.message('Not Set', name: 'notSet');
  }

  String get ttlExplanation {
    return Intl.message(
        'TTL: Time To Live. The period of time where the object is valid',
        name: 'ttlExplanation');
  }

  String get cacheTTLValueTitle {
    return Intl.message('Cache TTL value', name: 'cacheTTLValueTitle');
  }

  String get cacheTTLValueMessage {
    return Intl.message('Max period, in minutes', name: 'cacheTTLValueMessage');
  }

  String get infinite {
    return Intl.message('Infinite', name: 'infinite');
  }

  String get cacheTTL {
    return Intl.message('Cache TTL', name: 'cacheTTL');
  }

  String get enableCacheTTL {
    return Intl.message('Enable Cache TTL', name: 'enableCacheTTL');
  }

  String get minutes {
    return Intl.message('Minutes', name: 'minutes');
  }

  String get cacheAutoUpdateIntervalHint {
    return Intl.message('Interval, in minutes',
        name: 'cacheAutoUpdateIntervalHint');
  }

  String get cacheAutoUpdateIntervalTitle {
    return Intl.message('Cache Auto Update Interval',
        name: 'cacheAutoUpdateIntervalTitle');
  }

  String get cacheAutoUpdateIntervalMessage {
    return Intl.message('Select the desired update interval ( in minutes )',
        name: 'cacheAutoUpdateIntervalMessage');
  }

  String get clearCacheConfirmationTitle {
    return Intl.message('Clear Image Cache',
        name: 'clearCacheConfirmationTitle');
  }

  String get clearCacheConfirmationMessage {
    return Intl.message('Are you sure that you want to clear the images cache?',
        name: 'clearCacheConfirmationMessage');
  }

  String get clearCache {
    return Intl.message('Clear Cache', name: 'clearCache');
  }

  String get imagesCache {
    return Intl.message('Images Cache', name: 'imagesCache');
  }

  String get enableCache {
    return Intl.message('Enable Cache', name: 'enableCache');
  }

  String get enableCacheAutoUpdate {
    return Intl.message('Cache Auto Update', name: 'enableCacheAutoUpdate');
  }

  String get cacheAutoUpdateInterval {
    return Intl.message('Cache Auto Update Interval',
        name: 'cacheAutoUpdateInterval');
  }

  String get numberOfProducts {
    return Intl.message('Number of products', name: 'numberOfProducts');
  }

  String get apply {
    return Intl.message('Apply', name: 'apply');
  }

  String get country {
    return Intl.message('Country', name: 'country');
  }

  String get getInContactWithUs {
    return Intl.message('Get In Contact With Us', name: 'getInContactWithUs');
  }

  String get emailPasswordSignIn {
    return Intl.message('Email Password Sign In', name: 'emailPasswordSignIn');
  }

  String get emailReset {
    return Intl.message('Email to reset', name: 'emailReset');
  }

  String get getInTouchThroughSocial {
    return Intl.message('Get in touch with us throught the social pages below',
        name: 'getInTouchThroughSocial');
  }

  String get sendingMessage {
    return Intl.message('Sending message', name: 'sendingMessage');
  }

  String get send {
    return Intl.message('Send', name: 'send');
  }

  String get pleaseEnterMessage {
    return Intl.message('Please Enter Message', name: 'pleaseEnterMessage');
  }

  String get contactMessage {
    return Intl.message('Message', name: 'contactMessage');
  }

  String get contactEmail {
    return Intl.message('Contact Email', name: 'contactEmail');
  }

  String get emailSignUp {
    return Intl.message('Email Sign Up', name: 'emailSignUp');
  }

  String get enterConfirmationCode {
    return Intl.message('Enter Confirmation Code',
        name: 'enterConfirmationCode');
  }

  String get resetCode {
    return Intl.message('Reset Code', name: 'resetCode');
  }

  String get pleaseEnterResetCode {
    return Intl.message('Please Enter Reset Code',
        name: 'pleaseEnterResetCode');
  }

  String get reset {
    return Intl.message('Reset', name: 'reset');
  }

  String get resetPassword {
    return Intl.message('Reset Password', name: 'resetPassword');
  }

  String get clickToSaveUser {
    return Intl.message('Click to save user', name: 'clickToSaveUser');
  }

  String get signIn {
    return Intl.message('Sign In', name: 'signIn');
  }

  String get signUp {
    return Intl.message('Sign Up', name: 'signUp');
  }

  String get doesNotHaveAnAccount {
    return Intl.message('Does not have an account? Sign up!',
        name: 'doesNotHaveAnAccount');
  }

  String get alreadyHaveAnAccount {
    return Intl.message('Already have an account? Sign in!',
        name: 'alreadyHaveAnAccount');
  }

  String get orIfYouWishSignIn {
    return Intl.message('Or if you wish, Sign In', name: 'orIfYouWishSignIn');
  }

  String get orIfYouWishSignUp {
    return Intl.message('Or if you wish, Sign Up', name: 'orIfYouWishSignUp');
  }

  String get rememberMe {
    return Intl.message('Remember me', name: 'rememberMe');
  }

  String get thePasswordsMustMatch {
    return Intl.message('The Passwords must match',
        name: 'thePasswordsMustMatch');
  }

  String get confirmPassword {
    return Intl.message('Confirm Password', name: 'confirmPassword');
  }

  String get noComments {
    return Intl.message('No Comments', name: 'noComments');
  }

  String get errorLoadingAd {
    return Intl.message('Error loading ad', name: 'errorLoadingAd');
  }

  String get alphabetically {
    return Intl.message('Alphabetically', name: 'alphabetically');
  }

  String get random {
    return Intl.message('Random', name: 'random');
  }

  String get ascending {
    return Intl.message('Ascending', name: 'ascending');
  }

  String get descending {
    return Intl.message('Descending', name: 'descending');
  }

  String get creationDate {
    return Intl.message('Creation Date', name: 'creationDate');
  }

  String get updateDate {
    return Intl.message('Update Date', name: 'updateDate');
  }

  String get rating {
    return Intl.message('Rating', name: 'rating');
  }

  String get productUIDMustNotBeNull {
    return Intl.message('Product uid must not be null',
        name: 'productUIDMustNotBeNull');
  }

  String get sharingNotSupported {
    return Intl.message('Sharing Not Supported', name: 'sharingNotSupported');
  }

  String get yourBrowserDoesNotSupportShare {
    return Intl.message('Your browser does not support Share',
        name: 'yourBrowserDoesNotSupportShare');
  }

  String get created {
    return Intl.message('Created:', name: 'created');
  }

  String get updated {
    return Intl.message('Updated:', name: 'updated');
  }

  String get shareProduct {
    return Intl.message('Share product', name: 'shareProduct');
  }

  String get unavailable {
    return Intl.message('Unavailable', name: 'unavailable');
  }

  String get performanceOverlay {
    return Intl.message('Performance Overlay', name: 'performanceOverlay');
  }

  String get materialGrid {
    return Intl.message('Material Grid', name: 'materialGrid');
  }

  String get semanticsDebugger {
    return Intl.message('Semantics Debugger', name: 'semanticsDebugger');
  }

  String get logoffConfirmationTitle {
    return Intl.message('Logoff', name: 'logoffConfirmationTitle');
  }

  String get logoffConfirmationMessage {
    return Intl.message('Are you sure that you want to logoff?',
        name: 'logoffConfirmationMessage');
  }

  String get yes {
    return Intl.message('Yes', name: 'yes');
  }

  String get no {
    return Intl.message('No', name: 'no');
  }

  String get login {
    return Intl.message('Login', name: 'login');
  }

  String get logout {
    return Intl.message('Logout', name: 'logout');
  }

  String get authentication {
    return Intl.message('Authentication', name: 'authentication');
  }

  String get by {
    return Intl.message('by', name: 'by');
  }

  String get writtenIn {
    return Intl.message('Written in', name: 'writtenIn');
  }

  String get details {
    return Intl.message('Details', name: 'details');
  }

  String get comments {
    return Intl.message('Comments', name: 'comments');
  }

  String get invalidCharacters {
    return Intl.message('The name contains the following invalid characters:',
        name: 'invalidCharacters');
  }

  String get or {
    return Intl.message('or', name: 'or');
  }

  String get lastUpdate {
    return Intl.message('Last update:', name: 'lastUpdate');
  }

  String get invalidEmail {
    return Intl.message('Invalid EMail', name: 'invalidEmail');
  }

  String get dismiss {
    return Intl.message('Dismiss', name: 'dismiss');
  }

  String get unknownError {
    return Intl.message('Unknown Error', name: 'unknownError');
  }

  String get unknown {
    return Intl.message('Unknown', name: 'unknown');
  }

  String get notTheOwner {
    return Intl.message('You are not the owner of the element.',
        name: 'notTheOwner');
  }

  String get hasReferences {
    return Intl.message(
        'The element has references to it. Please remove them before deleting. They are: ',
        name: 'hasReferences');
  }

  String get doesNotExist {
    return Intl.message('The element does not exist', name: 'doesNotExist');
  }

  String get stateNotSupportedError {
    return Intl.message('State not supported', name: 'stateNotSupportedError');
  }

  String get title {
    return Intl.message('Title', name: 'title');
  }

  String get updating {
    return Intl.message('Updating', name: 'updating');
  }

  String get console {
    return Intl.message('Console', name: 'console');
  }

  String get thisPageShouldNotBeVisible {
    return Intl.message('This Page Should Not Be Visible',
        name: 'thisPageShouldNotBeVisible');
  }

  String get error {
    return Intl.message('Error', name: 'error');
  }

  String get home {
    return Intl.message('Home', name: 'home');
  }

  String get votes {
    return Intl.message('Votes', name: 'votes');
  }

  String get noInternetConnection {
    return Intl.message('No Internet Connection', name: 'noInternetConnection');
  }

  String get reloadingIn {
    return Intl.message('Reloading in', name: 'reloadingIn');
  }

  String get loading {
    return Intl.message('Loading...', name: 'loading');
  }

  String get loadingStory {
    return Intl.message('Loading Story...', name: 'loadingStory');
  }

  String get loadingProduct {
    return Intl.message('Loading Product...', name: 'loadingProduct');
  }

  String get loadingUniverse {
    return Intl.message('Loading Universe...', name: 'loadingUniverse');
  }

  String get loadingStories {
    return Intl.message('Loading Stories...', name: 'loadingStories');
  }

  String get loadingProducts {
    return Intl.message('Loading Products...', name: 'loadingProducts');
  }

  String get loadingUniverses {
    return Intl.message('Loading Universes...', name: 'loadingUniverses');
  }

  String get submit {
    return Intl.message('Submit', name: 'submit');
  }

  String get language {
    return Intl.message('Language', name: 'language');
  }

  String get pleaseSelectAnotherName {
    return Intl.message('The name already exists. Please select another',
        name: 'pleaseSelectAnotherName');
  }

  String get pleaseSelectAnotherCodename {
    return Intl.message('The name already exists. Please select another',
        name: 'pleaseSelectAnotherCodename');
  }

  String get pleaseSelectAnotherTitle {
    return Intl.message('The title already exists. Please select another',
        name: 'pleaseSelectAnotherTitle');
  }

  String get theNameIsEmpty {
    return Intl.message('The name must not be empty', name: 'theNameIsEmpty');
  }

  String get theTitleIsEmpty {
    return Intl.message('The title must not be empty', name: 'theTitleIsEmpty');
  }

  String get theCodenameIsEmpty {
    return Intl.message('The codename must not be empty',
        name: 'theCodenameIsEmpty');
  }

  String get pleaseLogIn {
    return Intl.message('Please Log In', name: 'pleaseLogIn');
  }

  String get clickBackButton {
    return Intl.message('Click the back button', name: 'clickBackButton');
  }

  String get noElement {
    return Intl.message('No element found', name: 'noElement');
  }

  String get emptyItems {
    return Intl.message('No items found', name: 'emptyItems');
  }

  String get productDeleted {
    return Intl.message('Product Deleted!', name: 'productDeleted');
  }

  String get storyDeleted {
    return Intl.message('Story Deleted!', name: 'storyDeleted');
  }

  String get universeDeleted {
    return Intl.message('Universe Deleted!', name: 'universeDeleted');
  }

  String get clickHereToGoBack {
    return Intl.message('Click here to go back', name: 'clickHereToGoBack');
  }

  String get noFurtherInformation {
    return Intl.message('No further information', name: 'noFurtherInformation');
  }

  String get errorUnknown {
    return Intl.message('Unknown error', name: 'errorUnknown');
  }

  String get errorTranslation {
    return Intl.message('There was a error translating the page :',
        name: 'errorTranslation');
  }

  String get disabled {
    return Intl.message('Disabled', name: 'disabled');
  }

  String get universe {
    return Intl.message('Universe', name: 'universe');
  }

  String get productSaved {
    return Intl.message('Product saved!', name: 'productSaved');
  }

  String get storySaved {
    return Intl.message('Story saved!', name: 'storySaved');
  }

  String get universeSaved {
    return Intl.message('Universe saved!', name: 'universeSaved');
  }

  String get searchProduct {
    return Intl.message('Search product...', name: 'searchProduct');
  }

  String get defaultLanguage {
    return Intl.message('Default Language', name: 'defaultLanguage');
  }

  String get translating {
    return Intl.message('Translating', name: 'translating');
  }

  String get licenses {
    return Intl.message('Licenses', name: 'licenses');
  }

  String get settings {
    return Intl.message('Settings', name: 'settings');
  }

  String get noUniverse {
    return Intl.message('No Universe', name: 'noUniverse');
  }

  String get noLanguage {
    return Intl.message('No Language', name: 'noLanguage');
  }

  String get post {
    return Intl.message('Post', name: 'post');
  }

  String get comment {
    return Intl.message('Comment', name: 'comment');
  }

  String get pleaseSelectAUniverse {
    return Intl.message('Please, select a universe',
        name: 'pleaseSelectAUniverse');
  }

  String get institutional {
    return Intl.message('Institutional', name: 'institutional');
  }

  String get about {
    return Intl.message('About', name: 'about');
  }

  String get contact {
    return Intl.message('Contact', name: 'contact');
  }

  String get social {
    return Intl.message('Social', name: 'social');
  }

  String get pleaseEnterPassword {
    return Intl.message('Please, enter Password', name: 'pleaseEnterPassword');
  }

  String get password {
    return Intl.message('Password', name: 'password');
  }

  String get stories {
    return Intl.message('Stories', name: 'stories');
  }

  String get errorLoginIn {
    return Intl.message('There was a error during login', name: 'errorLoginIn');
  }

  String get confirmationEmailSent {
    return Intl.message('A confirmation email has been sent to the address : ',
        name: 'confirmationEmailSent');
  }

  String get deleteConfirmationTitle {
    return Intl.message('Delete Item', name: 'deleteConfirmationTitle');
  }

  String get deleteConfirmationMessage {
    return Intl.message('Are you sure that you want to delete this item?',
        name: 'deleteConfirmationMessage');
  }

  String get noFriends {
    return Intl.message('No Friends', name: 'noFriends');
  }

  String get noEnemies {
    return Intl.message('No Enemies', name: 'noEnemies');
  }

  String get friends {
    return Intl.message('Friends:', name: 'friends');
  }

  String get enemies {
    return Intl.message('Enemies:', name: 'enemies');
  }

  String get confirm {
    return Intl.message('Confirm', name: 'confirm');
  }

  String get cancel {
    return Intl.message('Cancel', name: 'cancel');
  }

  String get edit {
    return Intl.message('Edit', name: 'edit');
  }

  String get delete {
    return Intl.message('Delete', name: 'delete');
  }

  String get allStories {
    return Intl.message('All Stories', name: 'allStories');
  }

  String get allUniverses {
    return Intl.message('All Universes', name: 'allUniverses');
  }

  String get views {
    return Intl.message('Views', name: 'views');
  }

  String get translateTo {
    return Intl.message('Translate To:', name: 'translateTo');
  }

  String get changeImage {
    return Intl.message('Change Image', name: 'changeImage');
  }

  String get signInWithPassword {
    return Intl.message('Sign in With Password', name: 'signInWithPassword');
  }

  String get signInWithGoogle {
    return Intl.message('Sign in With Google', name: 'signInWithGoogle');
  }

  String get signInWithFacebook {
    return Intl.message('Sign in With Facebook', name: 'signInWithFacebook');
  }

  String get signInWithTwitter {
    return Intl.message('Sign in With Twitter', name: 'signInWithTwitter');
  }

  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile');
  }

  String get failedSignIn {
    return Intl.message('Sign in failed', name: 'failedSignIn');
  }

  String get successfullySignInEmail {
    return Intl.message('Successfully signed in, email: ',
        name: 'successfullySignInEmail');
  }

  String get successfullySignInUID {
    return Intl.message('Successfully signed in, uid: ',
        name: 'successfullySignInUID');
  }

  String get pleaseEnterEmail {
    return Intl.message('Please enter your email.', name: 'pleaseEnterEmail');
  }

  String get email {
    return Intl.message('Email', name: 'email');
  }

  String get emailSignIn {
    return Intl.message('Email Sign In', name: 'emailSignIn');
  }

  String get receiveNotifications {
    return Intl.message('Receive Notifications', name: 'receiveNotifications');
  }

  String get userCountry {
    return Intl.message('User Country', name: 'userCountry');
  }

  String get userBirthdate {
    return Intl.message('User Birthdate', name: 'userBirthdate');
  }

  String get userNickname {
    return Intl.message('User Nickname', name: 'userNickname');
  }

  String get userSurename {
    return Intl.message('User Surename', name: 'userSurename');
  }

  String get userEmail {
    return Intl.message('User EMail', name: 'userEmail');
  }

  String get userName {
    return Intl.message('User Name', name: 'userName');
  }

  String get cropImage {
    return Intl.message('Crop Image', name: 'cropImage');
  }

  String get productCreateuniverse {
    return Intl.message('Create Universe', name: 'productCreateuniverse');
  }

  String get cropResult {
    return Intl.message('Crop Result', name: 'cropResult');
  }

  String get box {
    return Intl.message('Box', name: 'box');
  }

  String get oval {
    return Intl.message('Oval', name: 'oval');
  }

  String get cropShape {
    return Intl.message('Crop Shape', name: 'cropShape');
  }

  String get undo {
    return Intl.message('Undo', name: 'undo');
  }

  String get foregroundObject {
    return Intl.message('Foreground Object', name: 'foregroundObject');
  }

  String get crop {
    return Intl.message('Crop', name: 'crop');
  }

  String get cropFace {
    return Intl.message('Crop Face', name: 'cropFace');
  }

  String get imageSizeTooBig {
    return Intl.message('The file size is too big: }', name: 'imageSizeTooBig');
  }

  String get itShouldBeLessThan {
    return Intl.message('It  should be less than ', name: 'itShouldBeLessThan');
  }

  String get search {
    return Intl.message('Search...', name: 'search');
  }

  String get selectYourLanguage {
    return Intl.message('Select your language', name: 'selectYourLanguage');
  }

  String get productCreatestory {
    return Intl.message('Create Story', name: 'productCreatestory');
  }

  String get productStory {
    return Intl.message('Story', name: 'productStory');
  }

  String get productFriends {
    return Intl.message('Friends', name: 'productFriends');
  }

  String get productEnemies {
    return Intl.message('Enemies', name: 'productEnemies');
  }

  String get productUniverse {
    return Intl.message('Universe', name: 'productUniverse');
  }

  String get productProfession {
    return Intl.message('Profession', name: 'productProfession');
  }

  String get productCivilname {
    return Intl.message('Civil Name', name: 'productCivilname');
  }

  String get productTrainningplace {
    return Intl.message('Trainning place', name: 'productTrainningplace');
  }

  String get productBirthplace {
    return Intl.message('Bithplace', name: 'productBirthplace');
  }

  String get productLevel {
    return Intl.message('Level', name: 'productLevel');
  }

  String get productAge {
    return Intl.message('Age', name: 'productAge');
  }

  String get productHabilities {
    return Intl.message('Habilities', name: 'productHabilities');
  }

  String get productCodename {
    return Intl.message('Codename', name: 'productCodename');
  }

  String get productWeapons {
    return Intl.message('Weapons', name: 'productWeapons');
  }

  String get productName {
    return Intl.message('Name', name: 'productName');
  }

  String get publishedSubtitle {
    return Intl.message('Set true to publish', name: 'publishedSubtitle');
  }

  String get unpublished {
    return Intl.message('Unpublished', name: 'unpublished');
  }

  String get published {
    return Intl.message('Published', name: 'published');
  }

  String get level {
    return Intl.message('Level', name: 'level');
  }

  String get age {
    return Intl.message('Age', name: 'age');
  }

  String get text {
    return Intl.message('Text', name: 'text');
  }

  String get productFaceimage {
    return Intl.message('Face Image', name: 'productFaceimage');
  }

  String get productImage {
    return Intl.message('Image', name: 'productImage');
  }

  String get image {
    return Intl.message('Image', name: 'image');
  }

  String get story {
    return Intl.message('Story', name: 'story');
  }

  String get storyText {
    return Intl.message('Please enter story text', name: 'storyText');
  }

  String get pleaseEnterStory {
    return Intl.message('Please enter story text', name: 'pleaseEnterStory');
  }

  String get storyTitle {
    return Intl.message('Story Title', name: 'storyTitle');
  }

  String get close {
    return Intl.message('Close', name: 'close');
  }

  String get pickColor {
    return Intl.message('Pick a Color', name: 'pickColor');
  }

  String get empty {
    return Intl.message('Empty', name: 'empty');
  }

  String get myStories {
    return Intl.message('My Stories', name: 'myStories');
  }

  String get createStory {
    return Intl.message('Create Story', name: 'createStory');
  }

  String get myUniverses {
    return Intl.message('My Universes', name: 'myUniverses');
  }

  String get userLoggedOut {
    return Intl.message('User is currently signed out!', name: 'userLoggedOut');
  }

  String get userLoggedIn {
    return Intl.message('User Logged In!', name: 'userLoggedIn');
  }

  String get save {
    return Intl.message('Save', name: 'save');
  }

  String get saving {
    return Intl.message('Saving', name: 'saving');
  }

  String get pleaseEnterName {
    return Intl.message('Please enter a name', name: 'pleaseEnterName');
  }

  String get allProducts {
    return Intl.message('All Products', name: 'allProducts');
  }

  String get name {
    return Intl.message('Name', name: 'name');
  }

  String get universeName {
    return Intl.message('Name of the universe', name: 'universeName');
  }

  String get universeComment {
    return Intl.message('Comment', name: 'universeComment');
  }

  String get universes {
    return Intl.message('Universes', name: 'universes');
  }

  String get createUniverse {
    return Intl.message('Create Universe', name: 'createUniverse');
  }

  String get products {
    return Intl.message('Products', name: 'products');
  }

  String get myProducts {
    return Intl.message('My Products', name: 'myProducts');
  }

  String get createProduct {
    return Intl.message('Create a Product', name: 'createProduct');
  }

  String get appName {
    return Intl.message('The Productsbook', name: 'appName');
  }

  static Future<AppLocalizations> load(Locale locale) {
    final name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}
