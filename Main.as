class Main {
	static var ROWS:Number = 2
	static var COLS:Number = 4
	static var THUMB_WIDTH:Number = 104
	static var THUMB_HEIGHT:Number = THUMB_WIDTH*1.5
	
	static var page:Number = 0;
	static var imageClips:Array = new Array();
	static var placeHolderClips:Array = new Array(ROWS*COLS);
	static var uiElementClips:Array = new Array();
	static var cancelFunctions:Array = new Array();
	static var search:String = "";
	static var keyListeners:Object = new Array();
	
	static function init() {
		prepareHomePage(false, "");
	}
	
	static function cancelLoading() {
		for (var fun in cancelFunctions) {
			cancelFunctions[fun]();
		}
		while (cancelFunctions.length > 0) {
			cancelFunctions.pop();
		}
	}
	
	static function clearImages() {
		for (var clip in imageClips) {
			imageClips[clip].removeMovieClip();
		}
		while (imageClips.length > 0) {
			imageClips.pop();
		}
		for (var i in placeHolderClips) {
			placeHolderClips[i].removeMovieClip();
			placeHolderClips[i] = undefined;
		}
	}
	
	static function clearUI() {
		for (var clip in uiElementClips) {
			uiElementClips[clip].removeMovieClip();
			uiElementClips[clip].removeTextField();
			uiElementClips[clip] = undefined;
		}
		for (var i in keyListeners) {
			Key.removeListener(keyListeners[i]);
		}
		while (keyListeners.length > 0) {
			keyListeners.pop();
		}
	}
	
	static function prepareHomePage(skipUI:Boolean, Query:String) {
		search = Query;
		trace("LOADING PAGE:"+page+skipUI);

		cancelLoading();
		clearImages();
		if (skipUI != true) { //set up UI
			clearUI();
			
			var arrowR:MovieClip = _root.attachMovie("ArrowBtn", "arrowR", _root.getNextHighestDepth());
			arrowR._y = Stage.height-32;
			arrowR._x = Stage.width / 2 + 64;
			arrowR.onRelease = homePageRight;
			uiElementClips["arrowR"] = arrowR;

			var arrowL:MovieClip = _root.attachMovie("ArrowBtn", "arrowL", _root.getNextHighestDepth());
			arrowL._xscale = -100;
			arrowL._y = Stage.height-32;
			arrowL._x = Stage.width / 2 - 64;
			arrowL.onRelease = homePageLeft;
			uiElementClips["arrowL"] = arrowL;

			var pageNum:TextField = _root.createTextField("pageNum", _root.getNextHighestDepth(), Stage.width / 2 - 32, Stage.height-32, 64, 32);	
			pageNum.setNewTextFormat(new TextFormat("Arial", 24));
			pageNum.text = (page+1).toString();
			pageNum.autoSize="center";
			pageNum._y -= pageNum._height/2;
			uiElementClips["pageNum"]= pageNum;
			
			var searchBtn:MovieClip = _root.attachMovie("SearchBtn", "searchBtn", _root.getNextHighestDepth());
			searchBtn._y = searchBtn._height/2;
			searchBtn._x = Stage.width - searchBtn._width/2;
			searchBtn.onRelease = performSearch;
			uiElementClips["searchBtn"] = searchBtn;
			
			var searchBar:TextField = _root.createTextField("searchBar", _root.getNextHighestDepth(), 0, 0, Stage.width - searchBtn._width, searchBtn._height);
			searchBar.setNewTextFormat(new TextFormat("Arial", 24));
			searchBar.background = true;
			searchBar.backgroundColor = 16777215;
			searchBar.type = "input";
			searchBar.text = Query;
			uiElementClips["searchBar"] = searchBar;

			var keyListener:Object = new Object();
			keyListener.onKeyDown = function() {
				if (Key.isDown(Key.ENTER)) {
					performSearch();
				}
			}
			Key.addListener(keyListener)

		} else { //only update the page number
			uiElementClips["pageNum"].text = (page+1).toString()
		}
		
		//create placeholders
		for (var row = 0; row<ROWS; row++) {
			for (var col = 0; col<COLS; col++) {
				if (placeHolderClips[row*COLS + col] == undefined) {
					var placeholder = _root.attachMovie("MangaPlaceHolder", "cover_"+row+"_"+col, _root.getNextHighestDepth());
					placeholder._y = (Stage.height / (ROWS+1)) * (1+row) + 16;
					placeholder._x = (Stage.width / (COLS+1)) * (1+col);
					placeholder._width = THUMB_WIDTH;
					placeholder._height = THUMB_HEIGHT;
					placeHolderClips[row*COLS + col] = placeholder;
				}
			}
		}
		
		//fetch from API, then load images
		Api.fetchHomepageManga(function (a:Array) {
			for (var row = 0; row<ROWS; row++) {
				for (var col = 0; col<COLS; col++) {
					if (a[row*COLS + col] != undefined) {
						var cancelFunction = a[row*COLS + col].getCover(function(clip:MovieClip, row:Number, col:Number){
							placeHolderClips[row*COLS + col].removeMovieClip();
							placeHolderClips[row*COLS + col] = undefined;
							imageClips.push(clip);
							clip._y = (Stage.height / (ROWS+1)) * (1+row) - THUMB_HEIGHT/2 + 16;
							clip._x = (Stage.width / (COLS+1)) * (1+col) - THUMB_WIDTH/2;
							clip.onRelease = function () {
								prepareMangaDetails(a[row*COLS + col]);
							}
						}, row, col, THUMB_WIDTH, THUMB_HEIGHT);
						cancelFunctions.push(cancelFunction);
					} else {
						placeHolderClips[row*COLS + col].removeMovieClip();
						placeHolderClips[row*COLS + col] = undefined;
					}
				}
			}
		}, page ,ROWS * COLS, Query);
	}
	
	static function homePageLeft() {
		page = Math.max(page-1, 0);
		prepareHomePage(true, search);
	}
	static function homePageRight() {
		page+=1;
		prepareHomePage(true, search);
	}
	static function performSearch() {
		page = 0;
		prepareHomePage(true, uiElementClips["searchBar"].text)
	}
	static function returnHome() {
		prepareHomePage(false, search);
	}
	
	static function prepareMangaDetails(manga:Manga) {
		trace(manga.Title);
		clearUI();
		clearImages();
		cancelLoading();
		
		//set up UI
		var backBtn:MovieClip = _root.attachMovie("BackBtn", "backBtn", _root.getNextHighestDepth());
		backBtn._y = backBtn._height/2;
		backBtn._x = backBtn._width/2;
		backBtn.onRelease = returnHome;
		uiElementClips["backBtn"] = backBtn;

		var titleBar:TextField = _root.createTextField("titleBar", _root.getNextHighestDepth(), backBtn._width, 0, Stage.width - backBtn._width, backBtn._height);
		titleBar.setNewTextFormat(new TextFormat("Arial", 24));
		titleBar.background = true;
		titleBar.backgroundColor = 16777215;
		titleBar.text = manga.Title;
		uiElementClips["titleBar"] = titleBar;
		
		var info:TextField = _root.createTextField("info", _root.getNextHighestDepth(), Stage.width/5 ,backBtn._height, (1.5*Stage.width)/5, Stage.width/5 * 1.5);
		info.background = true;
		info.backgroundColor = 16777215;
		info.wordWrap = true;
		info.text = "Author: " + manga.Author + "\nArtist: " + manga.Artist + "\nTags:\n" + manga.Tags.join(", ");
		uiElementClips["info"] = info;
		
		var description:TextField = _root.createTextField("description", _root.getNextHighestDepth(), 0, Stage.width/5*1.5+backBtn._height, Stage.width/2, Stage.height - (Stage.width/5*1.5+backBtn._height));
		description.background = true;
		description.backgroundColor = 16777215;
		description.text = manga.Description;
		description.wordWrap = true;
		uiElementClips["description"] = description;
		
		var spinner = _root.attachMovie("spinner", "test", _root.getNextHighestDepth());
		spinner._y = backBtn._height + spinner._height*2;
		spinner._x = Stage.width/4*3 + spinner._width/2
		uiElementClips["chapterSpinner"] = spinner;

		var chapterProgress:TextField = _root.createTextField("chapterProgress", _root.getNextHighestDepth(), Stage.width/4*3 - 96, backBtn._height + spinner._height*2, 192, 32);
		chapterProgress.text = "0%";
		chapterProgress.autoSize="center";
		uiElementClips["chapterProgress"] = chapterProgress;
		
		manga.getCover(function(clip:MovieClip) {
			imageClips.push(clip);
			clip._y = backBtn._height
			clip._x = 0
		}, 0, 0, Stage.width/5, Stage.width/5 * 1.5);
		
		var cancelFunction = Api.fetchChapterList(function(chapters:Array) {
			//chapters finished loading
			chapterProgress.removeTextField();
			spinner.removeMovieClip();
			
			
			
		}, manga.ID, "en", function(loaded:Number, total:Number) {
			//loading progress notification
			chapterProgress.text = Math.round(loaded / total * 100) + "%"
		});
		cancelFunctions.push(cancelFunction);
	}
}