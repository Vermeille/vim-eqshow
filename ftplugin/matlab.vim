python << EOF
rules = [
# 0 Eq
    ([1, '=', 0], [Binop, 0, 1, 2]),
# 1 Plus
    ([2, '\+', 1], [Binop, 0, 1, 2]),
# 2 Minus
    ([3, '-', 2], [Binop, 0, 1, 2]),
# 3 Mul
    ([4, '\*', 3], [lambda x, y: Binop(x, '*', y), 0, 2]),
# 4 ElwiseDiv
    ([5, '\.', '\*', 4], [lambda x, y: Binop(x,'⊗', y), 0, 3]),
# 5 Div
    ([6, '/', 5], [Frac, 0, 2]),
# 6 ElwiseDiv
    ([7, '\.', '/', 6], [lambda x, y: Binop(x, '⊘', y), 0, 3]),
# 7 Power
    ([8, '\^',  7], [Super, 0, 2]),
# 8 Elwise Power
    ([9, '\.', '\^',  8], [Super, 0, 3]),
# 9 Transpose
    ([10, "'"], [lambda x: Super(x, Term('T')), 0]),
# 10 Term
    ([[12, 13, 14]], [lambda x: x, 0]),
# 11 Atomic
    (["(\w+)"], [Term, 0]),
# 12 Paren
    (['\(', 1, '\)'], [Paren, 1]),
# 13 Neg
    (['-', [11, 12]], [Neg, 1]),
# 14 Funcall
    ([11, '\(', 1, '\)'], [make_fun, 0, 2]),
# 15 Field Access
    ([11, '\.', 15], [lambda x, y: Term(x.txt + '.' + y.txt) if isinstance(y, Term) else x, 0, 2]),
# 16 CSV
    ([1, ',', 16], [lambda x, y: CSV([x] + (y.exprs if isinstance(y, CSV) else [y])), 0, 2]),
]
EOF
