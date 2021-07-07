class Chapter {
	var ID:String;
	var Hash:String;
	var Title:String;
	var Pages:Array;
	var Volume:String;
	var ChapterNum:String;
	var Group:String;
	
	function Chapter(ID:String, Hash:String, Title:String, Pages:Array, Volume:String, ChapterNum:String, Group:String) {
		this.ID = ID;
		this.Title = Title;
		this.Pages = new Array(Pages);
		this.Hash = Hash;
		this.Volume = Volume;
		this.ChapterNum = ChapterNum;
		this.Group = Group;
	}
}