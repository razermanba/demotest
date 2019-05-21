/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct Progress_data : Mappable {
	var id : String?
	var game_id : Int?
	var subgame_id : Int?
	var subgame_name : String?
	var subgame_course_id : Int?
	var course_title : String?
	var session_score : Int?
	var session_percent : Double?
	var session_created_at : String?
	var session_id : Int?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		id <- map["id"]
		game_id <- map["game_id"]
		subgame_id <- map["subgame_id"]
		subgame_name <- map["subgame_name"]
		subgame_course_id <- map["subgame_course_id"]
		course_title <- map["course_title"]
		session_score <- map["session_score"]
		session_percent <- map["session_percent"]
		session_created_at <- map["session_created_at"]
		session_id <- map["session_id"]
	}

}