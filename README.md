vim-code_block_markers
======================

Creating new code blocks and moving past code blocks are trivial tasks done all the time by software developers. Time can be saved by reducing the typing required to perform these tasks. This Vim editor plugin defines the following key mappings relating to code block markers for C, C++, Vimscript, and shell scripts:

<table>
<tr>
<td>&lt;Ctrl-k&gt;</td>
<td>Insert block start and end markers. Cursor is moved to the middle of the new block.
</tr>

<tr>
<td>jj</td>
<td>An insert mode mapping that continues insertion beyond current end of block.
</tr>

<tr>
<td>&lt;Ctrl-j&gt;</td>
<td>Insert an empty function argument list followed by block start and end markers.
</tr>
</table>



Setup
-----
[Vundle](https://github.com/gmarik/vundle) can be used to install and update this plugin.
