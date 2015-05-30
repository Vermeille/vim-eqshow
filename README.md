Vim-Eqshow
==========

## What's this?

Vim-eqshow pretty prints your maths formulas in a maths view.

If you have this code

```{matlab}
% <maths>
h = sigmoid(X * theta);
% </maths>
theta2 = theta(2:end,:);

% <maths>
J = (1 / m) * sum(-y .* log(h) - (1 - y) .* log(1 - h)) + lambda / m * sum(theta2 .^ 2);
% </maths>

theta2 = [0;theta(2:end,:)];
% <maths>
grad = (1 / m) * X' * (h - y) + lambda / m * theta2;
% </maths>
```

You can visualize the maths enclosed in <maths></maths> by enabling the maths view, and see:

```{matlab}
% <maths>
h = σ(X * θ)
% </maths>
theta2 = theta(2:end,:);

% <maths>

          ====                                           ====
     1    \                                          λ   \      2
J = (-) *  >  (-y ⊗ log(h) - (1 - y) ⊗ log(1 - h)) + - *  >  (θ2 )
     m    /                                          m   /
          ====                                           ====

% </maths>

theta2 = [0;theta(2:end,:)];
% <maths>
        1     T             λ
grad = (-) * X  * (h - y) + - * θ2
        m                   m
% </maths>
```

Then disable the maths view and continue to work.

## Install

You need Python2.7 suport.

With Vundle, simply add `Plugin 'Vermeille/vim-eqshow'` to your .vimrc, open vim, and run
`:PluginInstall`.

Without vundle:

```
git clone https://github.com/Vermeille/vim-eqshow ~/.vim/bundle/
```

then add something like

```
noremap <F4>  :EqShow<CR>
```

in your vimrc. Now, F4 toggles the maths view.

## Language support

Currently, vim-eqshow (roughly) supports:

* Python
* Matlab / Octave

If you want to add the support of a new language, write its grammar in its own
`ftplugin/<language>.vim`. Take example on already existing one.

The grammars are executed by a recursive descent parser

## Known issues

* Some language constructs are not supported => improve the grammar!
* Only one buffer at a time is supported now.
* Nothing prevents you from saving the pretty rendered file, and losing your code.
