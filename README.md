vim-code_block_markers
======================

Go from
```
int my_new_function
```
to:
```
int my_new_function()
{

}
```
with a single key-mapping with this plugin; The cursor will be positioned to begin entering the first statement of the function body.

Inserting and moving past code block markers are (trivial) tasks done all the time by software developers: This plugin can reduce the tedium. This Vim editor plugin defines key mappings for C, C++, C#, CMakeLists.txt, DOS batch, shell script and Vim script files.

<table>
<tr>
<td>&lt;Ctrl&gt;k</td>
<td>Insert block start and end markers. Cursor is moved to the middle of the new block.
</tr>

<tr>
<td>jj</td>
<td>An insert mode mapping that continues insertion beyond the end of the current block.
</tr>

<tr>
<td>&lt;Ctrl&gt;j</td>
<td>If the current line has an unmatched '(' then a ')' is inserted followed by block start and end markers. If there was no '(' then '()' (an empty function argument list) is inserted followed by block start and end markers.
</tr>
</table>


Setup
-----
[Vundle](https://github.com/gmarik/vundle) can be used to install and update this plugin.
