class Manga {
	var ID:String;
	var Title:String;
	var Tags:Array;
	var CoverURL:String;
	var Artist:String;
	var Author:String;
	var Chapters:Array;
	var Description:String;
	
	function Manga(ID:String, Title:String, Tags:Array, CoverURL:String, Artist:String, Author:String, Description:String) {
		this.ID = ID;
		this.Title = Title;
		this.Tags = new Array(Tags);
		this.CoverURL = CoverURL;
		this.Artist = Artist;
		this.Author = Author;
		this.Description = Description;
	}
	
	function getCover(callback:Function, row:Number, col:Number, wd:Number, ht:Number):Function {
		var mcHolder:MovieClip = _root.createEmptyMovieClip("cover_"+this.ID, _root.getNextHighestDepth());
		var mcLoader:MovieClipLoader = new MovieClipLoader();
		var listener:Object = {};
		var cancelled:Boolean = false;
		listener.onLoadInit = function (mc:MovieClip) {
			mc._width = wd;
			mc._height = ht;
		}
		listener.onLoadComplete = function(mc:MovieClip){
			if (not cancelled) {
				trace("onloadcomplete - callback")
				callback(mc, row, col);
			} else {
				trace("onloadcomplete - cancelled")
				mc.removeMovieClip();
			}
		}
		mcLoader.addListener(listener);	
		mcLoader.loadClip(Api.getCoverURL(this.ID, this.CoverURL), mcHolder);
		return function() {
			cancelled = true;
			mcLoader.loadClip(null, mcHolder);
		}
	}
}