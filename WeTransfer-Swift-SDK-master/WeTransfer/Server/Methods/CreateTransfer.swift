//
//  CreateTransfer.swift
//  WeTransfer
//
//  Created by Pim Coumans on 02/05/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

extension WeTransfer {

	/// Creates a transfer on the server and provides the given transfer object with an identifier and URL when succceeded.
	/// If the transfer object was initialized with files, the files will be added on the server as well and updated with the appropriate data
	///
	/// - Parameters:
	///   - message: Message to add to transfer
	///   - fileURLs: URLs pointing to local files
	///   - transfer: Transfer object that should be created on the server as well
	///   - completion: Closure that will be executed when the request or requests have finished
	///   - result: Result with either the updated transfer object or an error when something went wrong
	public static func createTransfer(saying message: String, fileURLs: [URL], completion: @escaping (_ result: Result<Transfer>) -> Void) {
		
		let callCompletion = { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}

		let creationOperation = CreateTransferOperation(message: message, fileURLs: fileURLs)
		
		creationOperation.onResult = callCompletion
		client.operationQueue.addOperation(creationOperation)
	}
}
