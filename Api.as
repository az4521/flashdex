class Api {
	static var BaseURL:String = "http://giganig.ga/dex/";
	
	static function fetchHomepageManga(callback:Function, page:Number, amount:Number, search:String):Void {
		trace("FETCHHOMEPAGE:" + page.toString());
		var url:String = BaseURL + "manga?order[updatedAt]=desc&limit="+amount+"&includes[]=cover_art&includes[]=artist&includes[]=author&offset=";
		url = url+(page*amount).toString()
		if (search!="") {
			url = url + "&title=" + search;
		}
		fetchText(url, function(returned:String) {
				  
			try{
				JSON.parse(returned, function(dat:Object) {
					trace("FETCHHOMEPAGE: Parsed JSON");
					var manga:Array = new Array();
					for (var i in dat["data"]) {
						var x = dat["data"][i];
						
						var ath:String;
						var art:String;
						var cov:String;
						for (var j in x["relationships"]) {
							var y=x["relationships"][j]
							if (y["type"]=="author") {
								ath = y["attributes"]["name"];
							} else if (y["type"]=="artist") {
								art = y["attributes"]["name"];
							} else if (y["type"]=="cover_art") {
								cov = y["attributes"]["fileName"];
							}
						}
						
						var tags:Array = new Array();
						for (var j in x["attributes"]["tags"]) {
							var y=x["attributes"]["tags"][j];
							tags.push(y["attributes"]["name"]["en"]);
						}
						
						manga.push(new Manga(x["id"], x["attributes"]["title"]["en"], tags, cov, art, ath, x["attributes"]["description"]["en"]));
					}
					manga.reverse()
					callback(manga);
				});
			} catch(ex) {
				trace(ex.name + ":" + ex.message + ":" + ex.at + ":" + ex.text);
			}
		});
	}
	
	static function fetchChapterList(callback:Function, mangaID:String, Lang:String, loading:Function):Void {
		trace("FETCHCHAPTERLIST");
		if (Lang==undefined) {Lang="en";}
		var url:String = BaseURL + "manga/"+mangaID+"/feed?limit=50&includes[]=scanlation_group&order[volume]=desc&order[chapter]=desc";
		url = url + "&translatedLanguage[]=" + Lang + "&offset=";
		fetchChaptersRecursive(function(chapters:Array) {
			callback(chapters);
		}, url, 0, loading);
	}
	
	private static function fetchChaptersRecursive(callback:Function, url:String, fetched:Number, loading:Function) {
		var chapters:Array = new Array();

		fetchText(url + fetched, function (str:String) {
			try {
				JSON.parse(str, function(dat:Object) {
					var amount = dat["data"].length + fetched;
					trace("fetched: "+amount + " total:" + dat["total"]);
					loading(amount, dat["total"]);
					for (var i in dat["data"]) {
						var d = dat["data"][i];
						var a = d["attributes"]
						var r = d["relationships"];
						
						var group:String = "";
						for (var j in r) {
							if (r[j]["type"]=="scanlation_group") {
								group = r[j]["attributes"]["name"];
							}
						}

						chapters.push(new Chapter(d["id"], a["hash"], a["title"], a["data"], a["volume"], a["chapter"], group));
					}
					
					if (amount < dat["total"]) {
						fetchChaptersRecursive(function (chp:Array) {
							callback(chapters.concat(chp));
						}, url, amount, loading);
					} else {
						callback(chapters);
					}
				});
			} catch(ex) {
				trace(ex.name + ":" + ex.message + ":" + ex.at + ":" + ex.text);
			}
		});
	}
	
	static function getCoverURL(mangaID:String, filename:String) {
		if (filename == undefined or mangaID == undefined) {
			return "http://crafty.moe/media/gunztile.png";
		}
		return "http://giganig.ga/covers/" + mangaID + "/" + filename + ".256.jpg";
	}
	
	private static function fetchText(url:String, callback:Function):Void {
		trace("FETCHTEXT:" + url);
		var x = new LoadVars();
		x.onData = function(src:String) {
			trace("fetchtext succeeded");
			callback(src);
		}
		x.load(url)
	}
}