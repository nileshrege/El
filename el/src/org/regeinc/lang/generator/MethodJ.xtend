package org.regeinc.lang.generator

import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.MethodBody
import org.regeinc.lang.el.MethodCall
import org.regeinc.lang.el.MethodDeclaration
import org.regeinc.lang.el.MethodDefinition
import org.regeinc.lang.el.Parameter

class MethodJ { 
	private new(){		
	}
	static MethodJ methodJ
	def static MethodJ instance(){
		if(methodJ==null)
			methodJ = new MethodJ()
		return methodJ
	}
		
	def compile(MethodDeclaration methodDeclaration)'''
		«IF methodDeclaration.parameterizedType!=null»«TypeJ::instance.compile(methodDeclaration.parameterizedType)» «ELSE»void «ENDIF»«
		methodDeclaration.name»(«IF methodDeclaration.parameter!=null»«compile(methodDeclaration.parameter)»«ENDIF»)'''
	
	def compile(Parameter parameter)'''
		«TypeJ::instance.compile(parameter.reference.parameterizedType)» «parameter.reference.name» «IF parameter.list»,«compile(parameter)»«ENDIF»'''
	
	def compile(MethodDefinition methodDefinition)'''
		«IF methodDefinition.visibility!=null»«methodDefinition.visibility.toString» «ENDIF»«IF methodDefinition.FINAL»final «
		ELSEIF methodDefinition.ABSTRACT»abstract «ENDIF»«compile(methodDefinition.methodDeclaration)»«IF methodDefinition.methodBody!=null»{
			«IF methodDefinition.constraint!=null»«ConditionJ::instance.applyConstraint(methodDefinition.constraint.condition, methodDefinition.methodDeclaration.name)»«ENDIF»
			«compile(methodDefinition.methodBody)»
		}«ELSE»;«ENDIF»
	'''
		
	def compile(MethodBody methodBody)'''
		«IF !methodBody.allStatement.nullOrEmpty»«
		FOR statement:methodBody.allStatement»«
			IF statement.blockStatement!=null»«BlockStatementJ::instance.compile(statement.blockStatement)»«
				ELSEIF statement.lineStatement!=null»«LineStatementJ::instance.compile(statement.lineStatement)»«ENDIF»
		«ENDFOR»«ENDIF»'''

	def compile(MethodCall methodCall)'''
		«IF methodCall.reference!=null»get«methodCall.reference.name.toFirstUpper»()«
		ELSE»«methodCall.methodDeclaration.name»(«IF methodCall.argument!=null»«compile(methodCall.argument)»«ENDIF»)«ENDIF»'''	

	def compile(Argument argument)'''
		«ExpressionJ::instance.compile(argument.expression)»«IF argument.list», «compile(argument.next)»«ENDIF»'''	
		
}