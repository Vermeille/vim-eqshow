" vim: set fileencoding=utf-8 :
python <<EOF
import re

##################################
## AST
##################################

greek = [
    ('Alpha', 'Α'),
    ('Beta', 'Β'),
    ('Gamma', 'Γ'),
    ('Delta', 'Δ'),
    ('Epsilon', 'Ε'),
    ('Zeta', 'Ζ'),
    ('Eta', 'Η'),
    ('Theta', 'Θ'),
    ('Iota', 'Ι'),
    ('Kappa', 'Κ'),
    ('Lambda', 'Λ'),
    ('Mu', 'Μ'),
    ('Nu', 'Ν'),
    ('Ksi', 'Ξ'),
    ('Omicron', 'Ο'),
    ('Pi', 'Π'),
    ('Rho', 'Ρ'),
    ('Sigma', 'Σ'),
    ('Tau', 'Τ'),
    ('Upsilon', 'Υ'),
    ('Phi', 'Φ'),
    ('Khi', 'Χ'),
    ('Psi', 'Ψ'),
    ('Omega', 'Ω'),

    ('alpha', 'α'),
    ('beta', 'β'),
    ('gamma', 'γ'),
    ('delta', 'δ'),
    ('epsilon', 'ε'),
    ('zeta', 'ζ'),
    ('theta', 'θ'),
    ('eta', 'η'),
    ('iota', 'ι'),
    ('kappa', 'κ'),
    ('lambda', 'λ'),
    ('mu', 'μ'),
    ('nu', 'ν'),
    ('ksi', 'ξ'),
    ('omicron', 'ο'),
    ('pi', 'π'),
    ('rho', 'ρ'),
    ('sigma', 'σ'),
    ('tau', 'τ'),
    ('upsilon', 'υ'),
    ('phi', 'φ'),
    ('khi', 'χ'),
    ('psi', 'ψ'),
    ('omega', 'ω'),
]

class Term(object):
    txt = ''
    def __init__(self, txt):
        self.txt = txt
        for g in greek:
            self.txt = self.txt.replace(*g)

    def size(self):
        return (len(self.txt.decode('utf-8')), 0, 0)

    def show(self, buf, (x, y)):
        return strbuf(self.txt.decode('utf-8'), buf, (x, y))

    def __repr__(self):
        return 'Term(' + self.txt + ')'

class Binop(object):
    op = '+'
    a = None
    b = None

    def __init__(self, a, binop, b):
        self.op = (' ' + binop + ' ').decode('utf-8')
        self.a = a
        self.b = b

    def size(self):
        (ax, a_up, a_down) = self.a.size()
        (bx, b_up, b_down) = self.b.size()
        return (ax + len(self.op) + bx, max(a_up, b_up), max(a_down, b_down))

    def show(self, buf, (x, y)):
        (ax, a_up, a_down) = self.a.size()
        (bx, b_up, b_down) = self.b.size()
        base_line = y + max(a_up, b_up)
        self.a.show(buf, (x, base_line - a_up))
        strbuf(self.op, buf, (x + ax, base_line))
        self.b.show(buf, (x + len(self.op) + ax, base_line - b_up))

    def __repr__(self):
        return 'Binop(' + repr(self.a) + ', ' + self.op.encode('utf-8') + ', ' + repr(self.b) + ')'

class Frac(object):
    top = None
    bottom = None

    def __init__(self, top, bottom):
        self.top = top
        self.bottom = bottom

    def size(self):
        (ax, a_up, a_down) = self.top.size()
        (bx, b_up, b_down) = self.bottom.size()
        return (max(ax, bx), a_up + a_down + 1, b_up + b_down + 1)

    def show(self, buf, (x, y)):
        (ax, a_up, a_down) = self.top.size()
        (bx, b_up, b_down) = self.bottom.size()
        y_up = a_up + a_down + 1
        xlen = max(ax, bx)
        xmiddle = xlen / 2
        self.top.show(buf, (x + xmiddle - ax / 2, y))
        strbuf('-' * xlen, buf, (x, y + y_up))
        self.bottom.show(buf, (x + xmiddle - bx / 2, y + y_up + 1))

    def __repr__(self):
        return 'Frac(' + repr(self.top) + ', ' + repr(self.bottom) + ')'

class Sum(object):
    fromm = None
    to = None
    expr = None

    def __init__(self, fromm, to, expr):
        self.fromm = fromm
        self.to = to
        self.expr = expr

    def size(self):
        (fx, f_up, f_down) = self.fromm.size()
        (tx, t_up, t_down) = self.to.size()
        (ex, e_up, e_down) = self.expr.size()
        fy = f_up + f_down + 1
        ty = t_up + t_down + 1
        sigmax = max(4, fx, tx) + ex
        sigma_up = max(2 + ty, e_up)
        sigma_down = max(2 + fy, e_down)
        return (sigmax, sigma_up, sigma_down)

    def show(self, buf, (x, y)):
        (fx, f_up, f_down) = self.fromm.size()
        (tx, t_up, t_down) = self.to.size()
        (ex, e_up, e_down) = self.expr.size()
        (sx, s_up, s_down) = self.size()
        fy = f_up + f_down + 1
        ty = t_up + t_down + 1
        # <maths>
        sigmax = max(0, (max(fx, tx) - 4) / 2)
        # </maths>
        # <maths>
        self.to.show(buf, (x + max(0, (fx - tx) / 2), y + s_up - 2 - ty))
        # </maths>

        strbuf("====", buf, (x + sigmax, y + s_up - 2))
        strbuf("\\", buf, (x + sigmax, y + s_up - 1))
        strbuf(" >", buf, (x + sigmax, y + s_up))
        strbuf("/", buf, (x + sigmax, y + s_up + 1))
        strbuf("====", buf, (x + sigmax, y + s_up + 2))

        self.fromm.show(buf, (x + max(0, (tx - fx) / 2), y + s_up + 3))

        self.expr.show(buf, (x + max(4, tx, fx), y + s_up - e_up))

class Super(object):
    sup = None
    expr = None

    def __init__(self, expr, sup):
        self.expr = expr
        self.sup = sup

    def size(self):
        (ex, e_up, e_down) = self.expr.size()
        (sx, s_up, s_down) = self.sup.size()
        return (ex + sx, e_up + s_up + s_down + 1, e_down)

    def show(self, buf, (x, y)):
        (ex, e_up, e_down) = self.expr.size()
        (sx, s_up, s_down) = self.sup.size()
        self.expr.show(buf, (x, y + s_up + s_down + 1))
        self.sup.show(buf, (x + ex, y))

    def __repr__(self):
        return 'Super(' + repr(self.sup) + ', ' + repr(self.expr) + ')'

class Sub(object):
    sub = None
    expr = None

    def __init__(self, expr, sub):
        self.expr = expr
        self.sub = sub

    def size(self):
        (ex, e_up, e_down) = self.expr.size()
        (sx, s_up, s_down) = self.sub.size()
        return (ex + sx, e_up, e_down + s_up + s_down + 1)

    def show(self, buf, (x, y)):
        (ex, e_up, e_down) = self.expr.size()
        (sx, s_up, s_down) = self.sub.size()
        self.expr.show(buf, (x, y))
        self.sub.show(buf, (x + ex, y + e_down + 1))

    def __repr__(self):
        return 'Sub(' + repr(self.sub) + ', ' + repr(self.expr) + ')'

class Paren(object):
    expr = None

    def __init__(self, expr):
        self.expr = expr

    def size(self):
        (ex, e_up, e_down) = self.expr.size()
        return (ex + 2, e_up, e_down)

    def show(self, buf, (x, y)):
        (ex, e_up, e_down) = self.expr.size()
        strbuf('(', buf, (x, y + e_up))
        self.expr.show(buf, (x + 1, y))
        strbuf(')', buf, (x + 1 + ex, y + e_up))

    def __repr__(self):
        return 'Paren(' + repr(self.expr) + ')'

class Neg(object):
    expr = None

    def __init__(self, expr):
        self.expr = expr

    def size(self):
        (ex, e_up, e_down) = self.expr.size()
        return (ex + 1, e_up, e_down)

    def show(self, buf, (x, y)):
        (ex, e_up, e_down) = self.expr.size()
        strbuf('-', buf, (x, y + e_up))
        self.expr.show(buf, (x + 1, y))

    def __repr__(self):
        return 'Neg(' + repr(self.expr) + ')'

class CSV(object):
    exprs = None

    def __init__(self, exprs):
        self.exprs = exprs

    def size(self):
        (x, up, down) = (0, 0, 0)
        for e in self.exprs:
            (ex, e_up, e_down) = e.size()
            (x, up, down) = (x + ex, max(up, e_up), max(down, e_down))
        self.ex = x
        self.e_up = up
        self.e_down = down
        return (x + (len(self.exprs) - 1) * 2, up, down)

    def show(self, buf, (x, y)):
        (ex, e_up, e_down) = self.exprs[0].size()
        self.exprs[0].show(buf, (x, y + self.e_up - e_up))
        for e in self.exprs[1:]:
            x += ex
            strbuf(', ', buf, (x, y + self.e_up))
            x += 2
            (ex, e_up, e_down) = e.size()
            e.show(buf, (x, y + self.e_up - e_up))

    def __repr__(self):
        r = ''
        for e in self.exprs:
            r += repr(e) + ', '
        return 'CSV(' + r + ')'

class Funcall(object):
    name = None
    args = None

    def __init__(self, nm, csv):
        self.name = nm
        self.args = csv

    def size(self):
        (fx, f_up, f_down) = self.name.size()
        (ax, a_up, a_down) = self.args.size()
        return (fx + 1 + ax + 1, max(f_up, a_up), max(f_down, a_down))

    def show(self, buf, (x, y)):
        (_, up, _) = self.size()
        (fx, f_up, f_down) = self.name.size()
        (ax, a_up, a_down) = self.args.size()
        self.name.show(buf, (x, y + up - f_up))
        x += fx
        strbuf('(', buf, (x, y + up - f_up))
        x += 1
        self.args.show(buf, (x, y + up - a_up))
        x += ax
        strbuf(')', buf, (x, y + up - f_up))

    def __repr__(self):
        return 'Funcall(' + repr(self.name) + ', ' + repr(self.args) + ')'

########################
## Utilities
########################

def get_buffer((x, y_up, y_down)):
    buf = []
    for i in range(y_up + y_down + 1):
        buf.append([' '] * x)
    return buf

def strbuf(s, b, (x, y)):
    for i in range(len(s)):
        b[y][x + i] = s[i]

######################################
## Parser
######################################

def make_fun(fun, args):
    if isinstance(fun, Term):
        if fun.txt == 'exp':
            return Super(Term('e'), args)
        if fun.txt == 'sigmoid':
            return Funcall(Term('sigma'), args)
        if fun.txt == 'sum':
            return Sum(Term(''), Term(''), Paren(args))
        if fun.txt == 'inv':
            return Super(Paren(args), Term('-1'))
    return Funcall(fun, args)

def parse(expr, eidx, rules, ridx):
    i = 0
    #print(expr, ridx)
    for r in rules[ridx][0]:
        if type(r) == list:
            for subrule in r:
                if parse(expr, eidx + i, rules, subrule):
                    break
        elif isinstance(r, int):
            parse(expr, eidx + i, rules, r)
        elif not isinstance(expr[eidx + i], str) or \
            re.search(r, expr[eidx + i]) == None:
                return False
        i += 1

    node = rules[ridx][1]
    args = []
    for a in node[1:]:
        args.append(expr[eidx + a])
    expr[eidx : eidx + len(rules[ridx][0])] = [node[0](*args)]
    return True

##################################
## Lexer
##################################

symbols = ['+', '-', '/', '*', '(', ')', ', ', '<', '>', '^', ';', '.', '=', "'"]

def lex(txt, syms):
    for s in syms:
        txt = txt.replace(s, ' ' + s + ' ')
    txt += ' $'
    return txt.split()

##################################
## Main
##################################

def make_ascii(txt):
  txt = lex(txt, symbols)
  parse(txt, 0, rules, 0)
  expr = txt
  sz = expr[0].size()
  b = get_buffer(sz)
  expr[0].show(b, (0, 0))
  for i in range(len(b)):
      b[i]  = ''.join(b[i]).rstrip()
  return b
EOF


python <<EOF
import vim

is_pretty = False

def eq_show_toggle():
  global is_pretty
  global raw
  print('is_pretty', is_pretty)
  vim.command('set modifiable')
  if not is_pretty:
    raw = vim.current.buffer[:]
    is_eq = False
    eq = ''

    cursor = vim.current.window.cursor
    del vim.current.buffer[:]
    for line in raw:
      if '<maths>' in line:
        is_eq = True
        vim.current.buffer.append(line)
      elif '</maths>' in line:
        is_eq = False
        indent = len(eq) - len(eq.lstrip())
        for eq_line in make_ascii(eq):
          vim.current.buffer.append(' ' * indent + eq_line)
        eq = ''
        vim.current.buffer.append(line)
      elif not is_eq:
        vim.current.buffer.append(line)
      else:
        eq += line

    del vim.current.buffer[0]
    vim.current.window.cursor = cursor
    is_pretty = True
    vim.command('set nomodifiable')
  else:
    cursor = vim.current.window.cursor
    vim.current.buffer[:] = raw
    vim.current.window.cursor = cursor

    is_pretty = False

def eq_show_off():
    if is_pretty:
        eq_show_toggle()
EOF

function! EqShow()
python <<EOF
eq_show_toggle()
EOF
endfunction

function! EqShowOff()
python << EOF
eq_show_off()
EOF
endfunction

command! -nargs=0 EqShow call EqShow()
command! -nargs=0 EqShowOff call EqShowOff()
autocmd BufWrite * EqShowOff
