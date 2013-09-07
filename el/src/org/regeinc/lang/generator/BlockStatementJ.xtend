package org.regeinc.lang.generator

import org.regeinc.lang.el.BlockStatement
import org.regeinc.lang.el.Else
import org.regeinc.lang.el.Guard
import org.regeinc.lang.el.If
import org.regeinc.lang.el.While
import org.regeinc.lang.el.For

class BlockStatementJ {
	private new(){		
	}
	static BlockStatementJ blockStatementJ
	def static BlockStatementJ instance(){
		if(blockStatementJ==null)
			blockStatementJ = new BlockStatementJ()
		return blockStatementJ
	}
	 
	def compile(BlockStatement blockStatement)'''
		«IF blockStatement.whileBlock!=null»«compile(blockStatement.whileBlock)»«
		ELSEIF blockStatement.forBlock!=null»«compile(blockStatement.forBlock)»«
		ELSEIF blockStatement.ifBlock!=null»«compile(blockStatement.ifBlock)»«
		ELSEIF  blockStatement.guardBlock!=null»«compile(blockStatement.guardBlock)»«ENDIF»
	'''

	def compile(While whyle)'''
		while(«ConditionJ::instance.compile(whyle.condition)»){
			«IF whyle.methodBody!=null»«MethodJ::instance.compile(whyle.methodBody)»«ENDIF»
		}
		'''

	def compile(For phor)'''
		for(«
			IF phor.reference!=null»«
				phor.reference.parameterizedType.type.name» «phor.reference.name» : «IF phor.listReference!=null»«phor.listReference.name»«ELSE»«ExpressionJ::instance.compile(phor.listInstance)»«ENDIF»«
			ELSE»«
				IF phor.localVariableDeclaration!=null»«LineStatementJ::instance.compile(phor.localVariableDeclaration)»«ELSE»;«ENDIF»«
				IF phor.condition!=null»«ConditionJ::instance.compile(phor.condition)»«ENDIF»;«
				IF phor.expression!=null»«ExpressionJ::instance.compile(phor.expression)»«ENDIF»«
			ENDIF
		»){
			«
			IF phor.methodBody!=null»«MethodJ::instance.compile(phor.methodBody)»«ENDIF»
		}
		'''

	def compile(If ef)'''
		if(«ConditionJ::instance.compile(ef.condition)»){
			«IF ef.methodBody!=null»«MethodJ::instance.compile(ef.methodBody)»«ENDIF»
		}«IF ef.elseBlock!=null»«compile(ef.elseBlock)»«ENDIF»
		'''

	def compile(Else els)'''
		else «IF(els.ifCondition!=null)»«compile(els.ifCondition)»«ELSE»{
			«IF els.methodBody!=null»«MethodJ::instance.compile(els.methodBody)»«ENDIF»
		}«ENDIF»
	'''

	def compile(Guard guard)'''
		try{
			«MethodJ::instance.compile(guard.methodBody)»
		}«FOR entity:guard.allEntity»catch(«entity.name» e){
			«guard.reference.name».handle(e);
		}«ENDFOR»
	'''
}