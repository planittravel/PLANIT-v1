//
//  chatViewController.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 6/5/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Photos
import Firebase
import JSQMessagesViewController
import SwiftGifOrigin

final class ChatViewController: JSQMessagesViewController {

    //Passed via segue
    var searchMode: String?
    
    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"
    
    var channelRef: DatabaseReference?
    
    private var messageRef: DatabaseReference?
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://planit-1493915149567.appspot.com")
    private var userIsTypingRef: DatabaseReference?
    private var usersTypingQuery: DatabaseQuery?
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    private var localTyping = false
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef?.setValue(newValue)
        }
    }
    
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let channelRefKey = SavedPreferencesForTrip["firebaseChannelKey"] as! String
        let channelsRef = Database.database().reference().child("channels")
        channelRef = channelsRef.child(channelRefKey)
        messageRef  = self.channelRef?.child("messages")
        self.senderId = Auth.auth().currentUser?.uid
        userIsTypingRef = self.channelRef?.child("typingIndicator").child(self.senderId)
        usersTypingQuery = self.channelRef?.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
        self.senderDisplayName = DataContainerSingleton.sharedDataContainer.emailAddress
        
        observeMessages()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Clear background
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.backgroundColor = UIColor.clear.cgColor
        self.view.backgroundColor = UIColor.clear
        
        //remove attachment icon
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.backgroundColor = UIColor(red: 201/255, green: 205/255, blue: 212/255, alpha: 1)
        self.inputToolbar.contentView.textView.backgroundColor = UIColor.white
        self.inputToolbar.contentView.textView.textColor = UIColor.black
        self.inputToolbar.contentView.tintColor = UIColor.blue
        self.inputToolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        self.inputToolbar.barStyle = .default
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "chatToFlightResults" {
            let destination = segue.destination as? flightResultsViewController
            destination?.searchMode = self.searchMode
        }
    }

    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        messageRef = (channelRef?.child("messages"))!
        let messageQuery = messageRef?.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery?.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!, let photoURL = messageData["photoURL"] as String! {
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef?.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = Storage.storage().reference(forURL: photoURL)
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gif(data: data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef?.child("typingIndicator")
        userIsTypingRef = (typingIndicatorRef?.child(senderId))!
        userIsTypingRef?.onDisconnectRemoveValue()
        usersTypingQuery = (typingIndicatorRef?.queryOrderedByValue().queryEqual(toValue: true))!
        
        usersTypingQuery?.observe(.value) { (data: DataSnapshot) in
            
             //You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef?.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        // 3
        itemRef?.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        isTyping = false
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef?.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef?.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef?.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef?.child(key)
        itemRef?.updateChildValues(["photoURL": url])
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.flatGreenSea())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
//        isTyping = textView.text != ""
    }
    
//    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
//    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
//        //Update preference vars if an existing trip
//        //Trip status
//        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
//        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
//        let lastVC = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "lastVC") as? NSString ?? NSString()
//        let timesViewed = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "timesViewed") as? NSDictionary ?? NSDictionary()
//        //New Trip VC
//        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
//        let tripID = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "tripID") as? NSString ?? NSString()
//        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
//        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
//        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
//        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
//        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
//        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
//        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
//        let numberDestinations = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "numberDestinations") as? NSNumber ?? NSNumber()
//        let nonSpecificDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "nonSpecificDates") as? NSDictionary ?? NSDictionary()
//        let firebaseChannelKey = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "firebaseChannelKey") as? NSString ?? NSString()
//
//        //Budget VC
//        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
//        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
//        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
//        //Suggested Destination VC
//        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
//        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
//        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
//        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
//        //Activities VC
//        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
//        //Ranking VC
//        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
//        let rankedPotentialTripsDictionary = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionary") as? [NSDictionary] ?? [NSDictionary]()
//        let rankedPotentialTripsDictionaryArrayIndex = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "rankedPotentialTripsDictionaryArrayIndex") as? NSNumber ?? NSNumber()
//
//        //SavedPreferences
//        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "finished_entering_preferences_status": finishedEnteringPreferencesStatus,"trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips,"numberDestinations":numberDestinations,"nonSpecificDates":nonSpecificDates, "rankedPotentialTripsDictionary": rankedPotentialTripsDictionary, "tripID": tripID,"lastVC": lastVC,"firebaseChannelKey": firebaseChannelKey,"rankedPotentialTripsDictionaryArrayIndex": rankedPotentialTripsDictionaryArrayIndex, "timesViewed": timesViewed] as NSMutableDictionary
//        
//        return fetchedSavedPreferencesForTrip
//    }
//    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
//        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
//        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
//        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
//        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
//    }
    
    //MARK: Actions
    @IBAction func doneButtonTouchedUpInside(_ sender: Any) {
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        if SavedPreferencesForTrip["lastVC"] as! String == "newTrip" {
            super.performSegue(withIdentifier: "chatToNewTrip", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "swiping" {
            super.performSegue(withIdentifier: "chatToSwiping", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "ranking" {
            super.performSegue(withIdentifier: "chatToRanking", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "hotelResults" {
            super.performSegue(withIdentifier: "chatToExploreHotels", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "booking" {
            super.performSegue(withIdentifier: "chatToBooking", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "flightSearch" {
            super.performSegue(withIdentifier: "chatToFlightSearch", sender: self)
        } else if SavedPreferencesForTrip["lastVC"] as! String == "flightResults" {
            super.performSegue(withIdentifier: "chatToFlightResults", sender: self)
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(Auth.auth().currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

    
