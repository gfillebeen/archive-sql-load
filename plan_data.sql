IF OBJECT_ID('[dbo].[Files_Temporary]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Files_Temporary];

CREATE TABLE [dbo].[Files_Temporary]
(
	[ID] int IDENTITY	,
	[FileName] nvarchar(255), 
	[TableName] nvarchar(255),
	[Year] int,
	[LocalStart] bit,
	[LocalComplete] bit,
	[RemoteStart] bit,
	[RemoteComplete] bit	
);

INSERT INTO Files_Temporary (FileName) 
	EXEC MASTER..xp_cmdshell 'dir D:\Documents\Programming\Mortgages\Data /b /a-d';

UPDATE Files_Temporary 
	SET TableName = SUBSTRING(FileName,0,CHARINDEX('_',filename)), [Year] = SUBSTRING(FileName,CHARINDEX('_',filename)+1,4);

DELETE FROM dbo.Files_Temporary WHERE TableName IS NULL	

