//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class RelayManager: NSObject {

	private var inProgress = false
	private var dbmessages = realm.objects(DBMessage.self).filter(falsepredicate)

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RelayManager = {
		let instance = RelayManager()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
			self.relayMessages()
		}

		let predicate = NSPredicate(format: "status == %@", STATUS_QUEUED)
		dbmessages = realm.objects(DBMessage.self).filter(predicate).sorted(byKeyPath: FMESSAGE_CREATEDAT)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func relayMessages() {

		if (FUser.currentId() != "") {
			if (Connectivity.isReachable()) {
				if (inProgress == false) {
					relayNextMessage()
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func relayNextMessage() {

		if let dbmessage = dbmessages.first {
			inProgress = true
			MessageRelay.send(dbmessage: dbmessage) { error in
				if (error == nil) {
					dbmessage.updateItem(status: STATUS_SENT)
				}
				self.inProgress = false
			}
		}
	}
}
