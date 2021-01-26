/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct Result : Mappable {
	var id : Int?
	var user_id : Int?
	var quiz_id : Int?
	var answers : Answers?
	var performance : Double?
	var deleted : Bool?
	var created_at : String?
	var updated_at : String?
	var total_correct : Int?
	var detail : Detail?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		id <- map["id"]
		user_id <- map["user_id"]
		quiz_id <- map["quiz_id"]
		answers <- map["answers"]
		performance <- map["performance"]
		deleted <- map["deleted"]
		created_at <- map["created_at"]
		updated_at <- map["updated_at"]
		total_correct <- map["total_correct"]
		detail <- map["detail"]
	}

}