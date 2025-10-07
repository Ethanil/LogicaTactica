class_name P

## Creates a variable expression with the given name.
static func v(name:String)->Var:
	return Var.new(name)

## Creates a integer constant expression with the given value.
static func ic(value:int) -> IntConst:
	return IntConst.new(value)

## Creates a string constant expression with the given value.
static func sc(value:String) -> StringConst:
	return StringConst.new(value)


## Creates a predicate function expression with the specified name and arguments.
## @param name The name of the predicate function.
## @param args An array of argument expressions.
static func fun(name: String, args: Array[Expr]) -> PredicateFunc:
	return PredicateFunc.new(name, args)

## Creates an equality expression (left == right).
static func eq(left: Expr, right: Expr) -> Equals:
	return Equals.new(left, right)

## Creates a not-equal expression (left != right).
static func neq(left: Expr, right: Expr) -> NotEquals:
	return NotEquals.new(left, right)

## Creates a greater-than expression (left > right).
static func gt(left: Expr, right: Expr) -> GreaterThan:
	return GreaterThan.new(left, right)

## Creates a greater-than-or-equal expression (left >= right).
static func ge(left: Expr, right: Expr) -> GreaterEqual:
	return GreaterEqual.new(left, right)

## Creates a less-than expression (left < right).
static func lt(left: Expr, right: Expr) -> LessThan:
	return LessThan.new(left, right)

## Creates a less-than-or-equal expression (left <= right).
static func le(left: Expr, right: Expr) -> LessEqual:
	return LessEqual.new(left, right)

## Creates an implication expression (premise → conclusion).
static func imp(premise: Expr, conclusion: Expr) -> Implies:
	return Implies.new(premise, conclusion)

## Creates a logical AND expression (left ∧ right).
static func a(left: Expr, right: Expr) -> And:
	return And.new(left, right)

## Creates a logical OR expression (left ∨ right).
static func o(left: Expr, right: Expr) -> Or:
	return Or.new(left, right)


## Creates a logical NOT expression (¬expr).
static func n(expr: Expr) -> Not:
	return Not.new(expr)

## Creates a union expression (left ∪ right).
static func un(left: Expr, right: Expr) -> Union:
	return Union.new(left, right)

## Creates an intersection expression (left ∩ right).
static func inter(left: Expr, right: Expr) -> Intersection:
	return Intersection.new(left, right)

## Creates an assignment expression (target := expr).
static func ass(target: Expr, expr: Expr) -> Assign:
	return Assign.new(target, expr)

## Creates a universal quantifier expression (∀varname ∈ domain: body).
static func fa(varname: String, domain: Expr, body: Expr) -> ForAll:
	return ForAll.new(varname, domain, body)

## Creates an existential quantifier expression (∃varname ∈ domain: body).
static func ex(varname: String, domain: Expr, body: Expr) -> Exists:
	return Exists.new(varname, domain, body)

## Creates a plus expression (left + right).
static func pl(left: Expr, right: Expr) -> Plus:
	return Plus.new(left, right)

## Creates a minus expression (left - right).
static func mi(left: Expr, right: Expr) -> Minus:
	return Minus.new(left, right)

## Creates a multiply expression (left * right).
static func mul(left: Expr, right: Expr) -> Mult:
	return Mult.new(left, right)

## Creates a divide expression (left / right).
static func div(left: Expr, right: Expr) -> Div:
	return Div.new(left, right)
