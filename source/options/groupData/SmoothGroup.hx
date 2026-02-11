package options.groupData;

class SmoothGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'Smooth Settings', TITLE);
		addOption(option);

        /////--Smooth Option--\\\\\

		var option:Option = new Option(this, 'Smooth', TEXT);
		addOption(option);

		var option:Option = new Option(this, 'smoothHealth', BOOL);
		addOption(option, true);

		var option:Option = new Option(this, 'smoothScore', BOOL);
		addOption(option, true);

		var option:Option = new Option(this, 'commaSeperated', BOOL);
		addOption(option, true);
		changeHeight(0); //初始化真正的height
	}
}
