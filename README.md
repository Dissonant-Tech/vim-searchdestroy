searchdestroy
=============

Easy to use Search and Replace mapping for vim.

After having used vim for a couple years I had almost every function I use mapped down to just a few keystrokes, 
except for vim's search and replace that is. With search(and)destroy you only need to hit `<leader>sd` while your cursor 
is over the word you'd liked replaced, type the new word, hit enter and done.

Examples
========

`<leader>sd`

In normal mode:
* Prompts for new word, replaces all occurences of the  word under the cursor with the new one. Only matches the __full word__.

In visual mode:
* Prompts for new word. Replaces all occurences of selected text with new word.
* If more than one word is selected prompts for text to be replaced, and for new text. Replaces all occurences in the selection.

Installation
============

Pathogen:

`git clone git://github.com/Dissonant-Tech/vim-searchdestroy.git ~/.vim/bundle/vim-searchdestroy`

or as a submodule:

```
cd ~/.vim

git submodule add git://github.com/Dissonant-Tech/vim-searchdestroy.git bundle/vim-searchdestroy
```

Caveats
=======

I've found that replacing a word with `<leader>sd` in normal mode will leave a trailing space afterwards.
