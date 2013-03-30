package org.regeinc.lang.generator

import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.MethodBody
import org.regeinc.lang.el.MethodCall
import org.regeinc.lang.el.MethodDeclaration
import org.regeinc.lang.el.MethodDefinition
import org.regeinc.lang.el.Parameter

import static extension org.regeinc.lang.generator.MethodJ.*
import org.regeinc.lang.el.DotMethodCall

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
		«IF methodDeclaration.returnType!=null»«methodDeclaration.returnType.name» «ELSE»void «ENDIF»«
		methodDeclaration.name»(«IF methodDeclaration.parameter!=null»«compile(methodDeclaration.parameter)»«ENDIF»)'''
	
	def compile(Parameter parameter)'''
		«parameter.qualifiedReference.reference.type.name» «parameter.qualifiedReference.reference.name» «IF parameter.list»,«compile(parameter)»«ENDIF»'''
	
	def compile(MethodDefinition methodDefinition)'''
		«IF methodDefinition.visibility!=null»«methodDefinition.visibility.toString» «ENDIF»«IF methodDefinition.FINAL»final «
		ELSEIF methodDefinition.ABSTRACT»abstract «ENDIF»«compile(methodDefinition.methodDeclaration)»«IF methodDefinition.methodBody!=null»{
			«IF methodDefinition.constraint!=null»«ConditionJ::instance.applyConstraint(methodDefinition.constraint.condition)»«ENDIF»
			«IF methodDefinition.methodDeclaration.parameter!=null»«
				IF methodDefinition.methodDeclaration.parameter.qualifiedReference.typePrefix!=null»«
					new TypePrefixJ(methodDefinition.methodDeclaration.parameter.qualifiedReference.reference.name)
						.applyConstraint(methodDefinition.methodDeclaration.parameter.qualifiedReference.typePrefix)»«
				ENDIF»«
			ENDIF»
			«compile(methodDefinition.methodBody)»
		}«ELSE»;«ENDIF»
	'''

	def prefix(Parameter parameter)'''
		«IF parameter.qualifiedReference.typePrefix!=null»«
			new TypePrefixJ(parameter.qualifiedReference.reference.name).applyConstraint(parameter.qualifiedReference.typePrefix)»«ENDIF»'''
	
	def compile(MethodBody methodBody)'''
		«IF !methodBody.allStatement.nullOrEmpty»«
		FOR statement:methodBody.allStatement»«
			IF statement.blockStatement!=null»«BlockStatementJ::instance.compile(statement.blockStatement)»«
				ELSEIF statement.lineStatement!=null»«LineStatementJ::instance.compile(statement.lineStatement)»«ENDIF»
		«ENDFOR»«ENDIF»'''

	def compile(MethodCall methodCall)'''
		«methodCall.methodDeclaration.name»(«IF methodCall.argument!=null»«compile(methodCall.argument)»«ENDIF»)'''	

	def compile(Argument argument)'''
		«ExpressionJ::instance.compile(argument.expression)»«IF argument.list», «compile(argument.next)»«ENDIF»'''	
	
	def compile(DotMethodCall dotMethodCall)'''
		.«compile(dotMethodCall.methodCall)»«IF dotMethodCall.dotMethodCall!=null»«compile(dotMethodCall.dotMethodCall)»«ENDIF»'''	
		
}