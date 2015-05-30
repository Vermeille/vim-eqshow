python << EOF
rules = [
# 0 Eq
    ([1, '=', 0], [Binop, 0, 1, 2]),
# 1 Plus
    ([2, '\+', 1], [Binop, 0, 1, 2]),
# 2 Minus
    ([3, '-', 2], [Binop, 0, 1, 2]),
# 3 Mul
    ([4, '\*', 3], [Binop, 0, 1, 2]),
# 4 Div
    ([5, '/', 4], [Frac, 0, 2]),
# 5 Term
    ([[7, 8, 9]], [lambda x: x, 0]),
# 6 Atomic
    (["(\w+)"], [Term, 0]),
# 7 Paren
    (['\(', 11, '\)'], [Paren, 1]),
# 8 Neg
    (['-', [6, 7]], [Neg, 1]),
# 9 Funcall
    ([10, '\(', 11, '\)'], [make_fun, 0, 2]),
# 10 Field Access
    ([6, '\.', 10], [lambda x, y: Term(x.txt + '.' + y.txt), 0, 2]),
# 11 CSV
    ([1, ',', 11], [lambda x, y: CSV([x] + (y.exprs if isinstance(y, CSV) else [y])), 0, 2]),
]
EOF
