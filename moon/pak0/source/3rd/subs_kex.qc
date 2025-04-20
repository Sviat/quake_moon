#define CONST_QEX_COLOR_WHITE 0
#define CONST_QEX_COLOR_GREEN 1
#define CONST_QEX_COLOR_TEAL 2
#define CONST_QEX_COLOR_YELLOW 3

//[byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext
void(string sender, float sender_color, string text) kex_chat_message_broad =
{
	WriteByte(MSG_ALL, svcqex_chat);
	WriteByte(MSG_ALL, sender_color);
	WriteByte(MSG_ALL, CONST_QEX_COLOR_TEAL);
	WriteString(MSG_ALL, sender);
	WriteString(MSG_ALL, text);
};

//[byte] svcqex_chat, [byte] playercolour, [byte] textcolour, [string] playername, [string] chattext
void(string sender, float sender_color, string text) kex_chat_message_self =
{
	local entity bak_entity;
	bak_entity = msg_entity;

	msg_entity = self;
	WriteByte(MSG_ONE, svcqex_chat);
	WriteByte(MSG_ONE, sender_color);
	WriteByte(MSG_ONE, CONST_QEX_COLOR_WHITE);
	WriteString(MSG_ONE, sender);
	WriteString(MSG_ONE, text);

	msg_entity = bak_entity;
};