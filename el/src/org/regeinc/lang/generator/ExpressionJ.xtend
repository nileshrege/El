package org.regeinc.lang.generator

import org.regeinc.lang.el.Addition
import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.DECIMAL_LITERAL
import org.regeinc.lang.el.Division
import org.regeinc.lang.el.Expression
import org.regeinc.lang.el.Instance
import org.regeinc.lang.el.ListInstance
import org.regeinc.lang.el.Literal
import org.regeinc.lang.el.NewInstance
import org.regeinc.lang.el.Substraction
import org.regeinc.lang.el.Select
import org.regeinc.lang.util.Finder
import org.regeinc.lang.el.Entity

class ExpressionJ{
	private new(){		
	}
	static ExpressionJ expressionJ
	def static ExpressionJ instance(){
		if(expressionJ==null)
			expressionJ = new ExpressionJ()
		return expressionJ
	}
	
	def compile(Expression expression)'''
	«IF expression.division!=null»«compile(expression.division)»«ENDIF»«IF expression.ASTERIX» * «compile(expression.expression)»«ENDIF»'''
	
	def compile(Division division)'''
	«IF division.addition!=null»«compile(division.addition)»«ENDIF»«IF division.PERCENT» % «compile(division.division)»«ENDIF»'''
	
	def compile(Addition addition)'''
	«IF addition.substraction!=null»«compile(addition.substraction)»«ENDIF»«IF addition.PLUS» + «compile(addition.addition)»«ENDIF»'''
	
	def compile(Substraction substraction)'''
		«compile(substraction.instance)»«IF substraction.HYPHEN» - «compile(substraction.substraction)»«ENDIF»'''
		
	def compile(Instance instance)'''
		«IF instance.groupExpression!=null»( «compile(instance.groupExpression)» )«
		ELSE»
			«IF instance.literal!=null»«compile(instance.literal)»«
			ELSEIF instance.listInstance!=null»«compile(instance.listInstance)»«
			ELSEIF instance.reference!=null»«instance.reference.name»«
			ELSEIF instance.newInstance!=null»«compile(instance.newInstance)»«ENDIF»«
			IF instance.methodCall!=null».«MethodJ::instance.compile(instance.methodCall)»«ENDIF»«
		ENDIF»'''
	
	def compile(NewInstance newInstance)'''
		new «newInstance.entity.name»(«IF newInstance.argument!=null»«ENDIF»)«
			IF !newInstance.allNestedInstance.nullOrEmpty»«
				FOR nestedInstance:newInstance.allNestedInstance
					».with«nestedInstance.qualifiedReference.reference.name.toFirstUpper»(«compile(nestedInstance.expression)»)«
				ENDFOR»«
			ENDIF»'''
	
	def compile(ListInstance listInstance)'''
		«IF listInstance.argument !=null»java.util.Arrays.asList(«compile(listInstance.argument)»)«
		ELSEIF listInstance.select !=null»«compile(listInstance.select)»«ELSE»new java.util.ArrayList()«ENDIF»'''	

	def compile(Select select)'''
		«IF select.CLAUSE»
		new java.util.ArrayList<«select.reference.type.name»>(){
			public List<«select.reference.type.name»> filter(List<«select.reference.type.name»> originalList){				
				List<«select.reference.type.name»> all«select.reference.type.name» = new ArrayList<>();
				for(Iterator<«select.reference.type.name»> it = originalList.iterator(); it.hasNext();){
					final «select.reference.type.name» «select.reference.name» = it.next();
					if(«ConditionJ::instance.compile(select.condition)»){
						all«select.reference.type.name».add(«select.reference.name»);
					}
				}
				return all«select.reference.type.name»;	
			}	
		}.filter(«select.listReference.name»)«ELSE»«select.listReference.name»«ENDIF»'''

	def compile(Argument argument)'''
		«compile(argument.expression)»«IF argument.list», «compile(argument.next)»«ENDIF»'''
	
	def compile(Literal literal)'''
		«IF literal.string!=null»«IF literal.string.length>0»«literal.string»«ELSE»""«ENDIF»«
		ELSEIF literal.number!=null»«compile(literal.number)»«
		ELSEIF literal.THIS!=null»this«
		ELSEIF literal.NULL!=null»null«
		ELSEIF literal.TRUE!=null»true«
		ELSEIF literal.FALSE!=null»false«ENDIF»'''

	def compile(DECIMAL_LITERAL decimal)'''
		«decimal.integer»«
			IF decimal.PERIOD».«decimal.fraction»«IF decimal.FLOATING»f«ENDIF»«ELSEIF decimal.TOOLONG»l«ENDIF»'''

}
