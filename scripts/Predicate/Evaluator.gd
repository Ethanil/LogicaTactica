class_name Evaluator
static var allies: Array[CreatureInstance] = []
static var enemies: Array[CreatureInstance] = []

static var function_context : Dictionary[StringName, Callable]= {
	"Verbündete": BattlefieldManager.get_allies,
	"Gegner": BattlefieldManager.get_enemies,
	"Kreaturen": BattlefieldManager.get_creatures,
	"Angriff": BattlefieldManager.get_attack,
	"Verteidigung": BattlefieldManager.get_defense,
	"Maximalleben": BattlefieldManager.get_max_health,
	"Leben": BattlefieldManager.get_cur_health,
	"Heile": BattlefieldManager.heal,
	"Spawn": BattlefieldManager.spawn_creature,
	"Anzahl": BattlefieldManager.length,
	"Eigenschaft": BattlefieldManager.has_attributes,
	"Summe": BattlefieldManager.sum
}

static var setter_context : Dictionary[StringName, Callable]= {
	"Angriff": BattlefieldManager.set_attack,
	"Verteidigung": BattlefieldManager.set_defense,
	"Maximalleben": BattlefieldManager.set_max_health,
	"Leben": BattlefieldManager.set_cur_health,
	"Verbündete": BattlefieldManager.set_allies,
	"Eigenschaft": BattlefieldManager.set_attributes
}


static func evaluate(expr: Expr, env: Dictionary = {}) -> Variant:
	match expr.type():
		Expr.VAR:
			return env.get(expr.name, expr.name)
		
		Expr.CONST:
			return expr.value
		
		Expr.PREDICATEFUNC:
			var fname = expr.name
			var args = expr.args.map(func(arg): return evaluate(arg, env))
			if function_context.has(fname):
				return function_context[fname].call(args)
			else:
				push_error("Unknown function: " + fname)
				return null
		
		Expr.EQUALS:
			return evaluate(expr.left, env) == evaluate(expr.right, env)
		Expr.NOTEQUALS:
			return evaluate(expr.left, env) != evaluate(expr.right, env)
		Expr.GREATERTHAN:
			return evaluate(expr.left, env) > evaluate(expr.right, env)
		Expr.GREATEREQUAL:
			return evaluate(expr.left, env) >= evaluate(expr.right, env)
		Expr.LESSTHAN:
			return evaluate(expr.left, env) < evaluate(expr.right, env)
		Expr.LESSEQUAL:
			return evaluate(expr.left, env) <= evaluate(expr.right, env)
		
		Expr.IMPLIES:
			var p = evaluate(expr.premise, env)
			if !p:
				return true
			var q = evaluate(expr.conclusion, env)
			return (not p) or q

		Expr.AND:
			var left = evaluate(expr.left, env)
			var right = evaluate(expr.right, env)
			return left and right
		
		Expr.OR:
			var left = evaluate(expr.left, env)
			var right = evaluate(expr.right, env)
			return left or right

		Expr.NOT:
			return not evaluate(expr.expr, env)

		Expr.ASSIGN:
			var fun = expr.target
			if(len(fun.args) > 1):
				push_error("Can't use a function with Arity > 1 in an assign")
				return null
			var setter_vals = []
			if(len(fun.args) == 1):
				setter_vals.append(evaluate(fun.args[0], env)) #this is the creature that will change
			setter_vals.append(evaluate(expr.expr, env))
			if setter_context.has(fun.name):
				setter_context[fun.name].call(setter_vals)
			else:
				push_error("Setter not found: " + fun.name)
			return true

		Expr.FORALL:
			var domain = evaluate(expr.domain, env)
			var result = true
			for thing in domain:
				var scoped_env = env.duplicate()
				scoped_env[expr.varname] = thing
				if !evaluate(expr.body, scoped_env):
					result = false
			return result

		Expr.EXISTS:
			var domain = evaluate(expr.domain, env)
			var result = false
			for thing in domain:
				var scoped_env = env.duplicate()
				scoped_env[expr.varname] = thing
				if evaluate(expr.body, scoped_env):
					result = true
			return result


		Expr.UNION:
			return evaluate(expr.left, env) + evaluate(expr.right, env)

		Expr.INTERSECTION:
			var left = evaluate(expr.left, env)
			var right = evaluate(expr.right, env)
			var res:Array = []
			for l in left:
				if right.has(l):
					res.append(l)
			return res
		
		Expr.PLUS:
			return evaluate(expr.left, env) + evaluate(expr.right, env)
		
		Expr.MINUS:
			return evaluate(expr.left, env) - evaluate(expr.right, env)
		
		Expr.MULT:
			return evaluate(expr.left, env) * evaluate(expr.right, env)
		
		Expr.DIV:
			return evaluate(expr.left, env) / evaluate(expr.right, env)
		
		_:
			push_error("Unknown expression type")
			return null

static func to_latex(expr:Expr) -> String:
	var result = ""
	var latex = _to_latex(expr)
	var found_align_char = false
	var found_align_char_one_over = false
	var index = 0
	for _i in len(latex):
		if index >= len(latex):
			break
		var latex_char = latex[index]
		if latex_char == '&':
			if found_align_char_one_over:
				found_align_char = true
			else:
				found_align_char = true
				found_align_char_one_over = true
				result += latex_char
		else:
			if found_align_char:
				found_align_char = false
				if index + len("\\rightarrow &") < len(latex) and latex.substr(index, len("\\rightarrow &")) == "\\rightarrow &":
					result += "\\rightarrow "
					index += len("\\rightarrow &") + 1
					found_align_char = true
					continue
				if index + len("\\lnot &") < len(latex) and latex.substr(index, len("\\lnot &")) == "\\lnot &":
					result += "\\lnot "
					index += len("\\lnot &")
					found_align_char = true
					continue
				if index + len(indention_symbol) < len(latex) and latex.substr(index, len(indention_symbol)) == indention_symbol:
					result += indention_symbol
					index += len(indention_symbol)
					found_align_char = true
					continue
			elif found_align_char_one_over:
					found_align_char_one_over = false
			result += latex_char
		index += 1
	result = "\\begin{align} %s \\end{align}" % result
	return result

static var indention_symbol := "\\quad "

static func _to_latex(expr:Expr, indentation_amount:int = 0) -> String:
	match expr.type():
		Expr.VAR: return "\\text{%s}" % expr.name
		Expr.CONST: return "\\text{%s}" % str(expr.value)
		Expr.PREDICATEFUNC: return "%s(%s)" % [expr.name, ", ".join(expr.args.map(_to_latex))] if len(expr.args) > 0 else "%s" % [expr.name]
		Expr.EQUALS: return "%s = %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.NOTEQUALS: return "%s \\neq %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.GREATERTHAN: return "%s > %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.GREATEREQUAL: return "%s \\ge %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.LESSTHAN: return "%s < %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.LESSEQUAL: return "%s \\le %s" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.IMPLIES: return "&%s \\\\ &%s\\rightarrow %s" % [_to_latex(expr.premise, indentation_amount),indention_symbol.repeat(indentation_amount + 1), _to_latex(expr.conclusion, indentation_amount + 1)]
		Expr.AND: return "&(%s \\land \\\\ &%s%s)" % [_to_latex(expr.left, indentation_amount),indention_symbol.repeat(indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.OR: return "&(%s \\lor \\\\ &%s%s)" % [_to_latex(expr.left, indentation_amount),indention_symbol.repeat(indentation_amount), _to_latex(expr.right, indentation_amount )]
		Expr.NOT: return "\\lnot %s" % _to_latex(expr.expr, indentation_amount)
		Expr.ASSIGN: return "%s := %s" % [_to_latex(expr.target, indentation_amount), _to_latex(expr.expr, indentation_amount)]
		Expr.FORALL: return "&\\forall %s \\in %s:\\  \\\\ &%s%s" % [expr.varname, _to_latex(expr.domain, indentation_amount),indention_symbol.repeat(indentation_amount + 1), _to_latex(expr.body, indentation_amount + 1)]
		Expr.EXISTS: return "&\\exists %s \\in %s:\\  \\\\ &%s%s" % [expr.varname, _to_latex(expr.domain, indentation_amount),indention_symbol.repeat(indentation_amount + 1), _to_latex(expr.body, indentation_amount + 1)]
		Expr.UNION: return "&(%s \\text{ }\\cup \\\\ &%s%s)" % [_to_latex(expr.left, indentation_amount),indention_symbol.repeat(indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.INTERSECTION: return "&(%s \\text{ }\\cap \\\\ &%s%s)" % [_to_latex(expr.left, indentation_amount),indention_symbol.repeat(indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.PLUS: return "(%s + %s)" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.MINUS: return "(%s - %s)" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.MULT: return "(%s \\cdot %s)" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		Expr.DIV: return "\\left(\\frac{%s}{%s}\\right)" % [_to_latex(expr.left, indentation_amount), _to_latex(expr.right, indentation_amount)]
		_: return "?"

static func update_latex(node:Latex, expr:Expr) -> void:
	if expr != null:
		var latex = to_latex(expr)
		await node.set_latex_expression(latex)
