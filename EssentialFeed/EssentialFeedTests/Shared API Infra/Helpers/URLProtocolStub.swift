//
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

class URLProtocolStub: URLProtocol {
	private struct Stub {
		let data: Data?
		let response: URLResponse?
		let error: Error?
		let requestObserver: ((URLRequest) -> Void)?
	}
	
	private static var _stub: Stub?
	private static var stub: Stub? {
		get { return queue.sync { _stub } }
		set { queue.sync { _stub = newValue } }
	}
	
	private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
	
	static func stub(data: Data?, response: URLResponse?, error: Error?) {
		print("==> [URLProtocolStub] stub")
		stub = Stub(data: data, response: response, error: error, requestObserver: nil)
	}
	
	static func observeRequests(observer: @escaping (URLRequest) -> Void) {
		print("==> [URLProtocolStub] observeRequests")
		stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
	}

	static func removeStub() {
		print("==> [URLProtocolStub] removeStub")
		stub = nil
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		print("===> [URLProtocolStub] canInit")
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		print("===> [URLProtocolStub] canonicalRequest")
		return request
	}
	
	override func startLoading() {
		print("===> [URLProtocolStub] startLoading")
		guard let stub = URLProtocolStub.stub else {
			print("===> [URLProtocolStub] no stub, return")
			return
		}

		if let data = stub.data {
			print("===> [URLProtocolStub] received data")
			client?.urlProtocol(self, didLoad: data)
		}

		if let response = stub.response {
			print("===> [URLProtocolStub] received response")
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		}

		if let error = stub.error {
			print("===> [URLProtocolStub] received error")
			client?.urlProtocol(self, didFailWithError: error)
		} else {
			print("===> [URLProtocolStub] call urlProtocolDidFinishLoading")
			client?.urlProtocolDidFinishLoading(self)
		}

		print("===> [URLProtocolStub] pass request to observer")
		stub.requestObserver?(request)
	}
	
	override func stopLoading() {}
}
