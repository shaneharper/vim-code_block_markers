vim-code_block_markers
======================

This Vim editor plugin defines key mappings for inserting code block markers and moving past code block markers in C, C++, Vimscript and shell scripts. Inserting and moving past code block markers are (trivial) tasks done all the time by software developers: This plugin can reduce the tedium.

<table>
<tr>
<td>&lt;Ctrl&gt;k</td>
<td>Insert block start and end markers. Cursor is moved to the middle of the new block.
</tr>

<tr>
<td>jj</td>
<td>An insert mode mapping that continues insertion beyond current end of block.
</tr>

<tr>
<td>&lt;Ctrl&gt;j</td>
<td>If the current line has an unmatched '(' then a ')' is inserted followed by block start and end markers. If there was no '(' then '()' (an empty function argument list) is inserted followed by block start and end markers.
</tr>
</table>


Example
-------
Typing &lt;Ctrl&gt;j after entering the start of the following C function
```
int my_function
```
results in:
```
int my_function()
{

}
```
with the cursor inside the {}s. Typing jj (j quickly followed by another j) while still in insert mode will move the cursor to the line past the '}' at the end of the function definition.


Setup
-----
[Vundle](https://github.com/gmarik/vundle) can be used to install and update this plugin.
